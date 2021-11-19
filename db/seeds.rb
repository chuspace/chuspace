# frozen_string_literal: true

chuspace_user = User.create_with_email_identity(email: 'gaurav@chuspace.com')
chuspace_user.save!

chuspace_storage = chuspace_user.storages.create!(
  default: true,
  active: true,
  provider: :chuspace,
  **GitStorageConfig.new.chuspace
)

github_storage = chuspace_user.storages.create!(
  active: true,
  description: 'Github storage to connect Chuspace blog',
  **GitStorageConfig.new.github.merge(
    access_token: Rails.application.credentials.storage[:github][:access_token]
  )
)

templates = JSON.parse(Rails.root.join('db/defaults/templates.json').read)
templates.each do |template|
  github_storage.blog_templates.create(
    author: chuspace_user,
    **template
  )
end

template = github_storage.blog_templates.first
# Connect blog
github_storage.blogs.create!(
  user: chuspace_user,
  name: 'Chuspace',
  default: true,
  visibility: :public,
  template: template,
  repository_attributes: {
    name: 'chuspace/blog',
    **template.repository_attributes
  }
)

# Create blog
template_2 = github_storage.blog_templates.second
chuspace_storage.blogs.create!(
  user: chuspace_user,
  name: 'Chuspace Internal',
  visibility: :public,
  template: template_2,
  repository_attributes: {
    name: "#{chuspace_user.username}/chuspace-internal",
    **template_2.repository_attributes
  }
)
