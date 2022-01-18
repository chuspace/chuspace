# frozen_string_literal: true

module Publications
  module Drafts
    class BaseController < ApplicationController
      include Breadcrumbable
      before_action :authenticate!, :find_publication, :find_draft
      layout 'editor'

      private

      def find_draft
        @draft = @publication.git_repository.draft(path: params[:path])
        add_breadcrumb(@publication.repo_drafts_or_posts_folder, publication_drafts_path(@publication, path: @publication.repo_drafts_or_posts_folder))
        add_breadcrumb(@draft.name, publication_edit_draft_path(@publication, @draft))
      end

      def find_publication
        @publication = Publication.friendly.find(params[:publication_permalink])
        add_breadcrumb(@publication.permalink, publication_path(@publication))
      end
    end
  end
end
