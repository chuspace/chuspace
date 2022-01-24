# frozen_string_literal: true

module Publications
  module Drafts
    class BaseController < ApplicationController
      before_action :authenticate!
      include Breadcrumbable, SetPublicationRoot
      before_action :find_draft

      layout 'editor'

      private

      def find_draft
        @draft = @publication.git_repository.draft(path: @draft_path)
        add_breadcrumb(:drafts, publication_drafts_root_path(@publication))
        add_breadcrumb(@draft.name, publication_edit_draft_path(@publication, @draft))
      end
    end
  end
end
