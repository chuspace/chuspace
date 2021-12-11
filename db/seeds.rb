# frozen_string_literal: true

chuspace_user = User.build_with_email_identity(
  email: 'gaurav@chuspace.com',
  username: 'gaurav88',
  name: 'Gaurav Tiwari'
)
chuspace_user.save!

chuspace_storage = chuspace_user.create_chuspace_storage!(
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
  chuspace_user.blog_templates.create(template)
end

template = chuspace_user.blog_templates.first
# Connect blog
personal_blog = github_storage.blogs.create!(
  owner: chuspace_user,
  name: 'blog',
  personal: true,
  visibility: :public,
  template: template,
  repo_fullname: 'chuspace/blog',
  **template.blog_attributes
)

chuspace_user.memberships.create(
  blog: personal_blog,
  role: :owner
)

# Create blog
template_2 = chuspace_user.blog_templates.second
other_blog = chuspace_storage.blogs.create!(
  owner: chuspace_user,
  name: 'Rails metaprogramming',
  visibility: :public,
  template: template_2,
  **template_2.blog_attributes
)

chuspace_user.memberships.create(
  blog: other_blog,
  role: :owner
)
