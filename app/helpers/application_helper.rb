# frozen_string_literal: true

module ApplicationHelper
  def logo
    signed_in? ? 'Chu' : 'Chuspace'
  end

  def link_class(path)
    current_page?(path) ? 'font-bold underline' : ''
  end

  def login_button_colors_classes
    {
      github: ['bg-github-light text-primary-content', 'hover:bg-github-dark'],
      gitlab: ['bg-gitlab-light text-dark', 'hover:bg-gitlab-dark'],
      bitbucket: ['bg-bitbucket-light text-primary-content', 'hover:bg-bitbucket-dark'],
      gitea: ['bg-gitea-light text-dark', 'hover:bg-gitea-dark'],
      email: ['bg-primary-content', 'hover:btn-secondary'],
    }.with_indifferent_access.freeze
  end

  def button_or_link_to(name = nil, options = nil, html_options = nil, &block)
    get_request = options[:method] == :get || options[:method].blank?
    get_request ? link_to(name, options, html_options, &block) : button_to(name, options, html_options, &block)
  end

  def tab_link_to(title, path, options = {})
    active_condition = options.delete(:active_condition) || :exact

    active = is_active_link?(path, active_condition)
    class_name = options.delete(:class) || ''
    class_name += ' active' if active

    link_to title, path, class: class_name, role: 'tab', 'aria-selected': active, tabindex: '-1', **options
  end

  def user_menu
    {
      overview: { label: 'Overview', tab: nil },
      publications: { label: 'Publications', tab: :publications },
      posts: { label: 'Posts', tab: :posts },
      drafts: { label: 'Drafts', tab: :drafts },
      settings: { label: 'Settings', tab: :settings }
    }.freeze
  end

  def url_or_mailto?(url_str)
    url = URI.parse(url_str)
    url.kind_of?(URI::HTTP) || url.kind_of?(URI::HTTPS) || url.kind_of?(URI::MailTo)
  end

  def is_active_link?(path, condition = nil)
    case condition
    when :inclusive, nil
      !request.fullpath.match(/^#{Regexp.escape(path).chomp('/')}(\/.*|\?.*)?$/).blank?
    when :exclusive
      !request.fullpath.match(/^#{Regexp.escape(path)}\/?(\?.*)?$/).blank?
    when Regexp
      !request.fullpath.match(condition).blank?
    else
      request.fullpath == path
    end
  end
end
