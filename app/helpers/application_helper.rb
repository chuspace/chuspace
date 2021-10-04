# frozen_string_literal: true

module ApplicationHelper
  def link_class(path)
    default_class = 'link link--default'
    current_page?(path) ? default_class + ' link--active font-bold' : default_class
  end

  def login_button_colors_classes
    {
      github: ['bg-github-light', 'hover:bg-github-dark'],
      gitlab: ['bg-gitlab-light', 'hover:bg-gitlab-dark'],
      bitbucket: ['bg-bitbucket-light', 'hover:bg-bitbucket-dark'],
      email: ['bg-accent-400', 'hover:bg-accent-500'],
    }.with_indifferent_access.freeze
  end
end
