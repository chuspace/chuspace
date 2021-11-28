# frozen_string_literal: true

module ApplicationHelper
  def link_class(path)
    current_page?(path) ? 'font-bold' : ''
  end

  def login_button_colors_classes
    {
      github: ['bg-github-light text-primary-content', 'hover:bg-github-dark'],
      gitlab: ['bg-gitlab-light text-dark', 'hover:bg-gitlab-dark'],
      bitbucket: ['bg-bitbucket-light text-primary-content', 'hover:bg-bitbucket-dark'],
      email: ['btn-accent'],
    }.with_indifferent_access.freeze
  end

  def button_or_link_to(name = nil, options = nil, html_options = nil, &block)
    get_request = options[:method] == :get || options[:method].blank?
    get_request ? link_to(name, options, html_options, &block) : button_to(name, options, html_options, &block)
  end

  def tab_selected?(path)
    request.fullpath == path ? 'font-bold border-b-2 pb-1' : ''
  end

  def user_menu
    {
      about: { label: 'About', tab: nil },
      posts: { label: 'Posts', tab: :posts },
      drafts: { label: 'Drafts', tab: :drafts },
      blogs: { label: 'Blogs', tab: :blogs },
      storages: { label: 'Storages', tab: :storages },
      settings: { label: 'Settings', tab: :settings }
    }.freeze
  end
end
