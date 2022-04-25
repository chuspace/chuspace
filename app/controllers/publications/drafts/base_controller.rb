# frozen_string_literal: true

module Publications
  module Drafts
    class BaseController < ApplicationController
      include Breadcrumbable
      include FindPublication
      include SetPublicationRoot

      prepend_before_action :authenticate!
      before_action :find_draft

      layout 'editor'

      private

      def find_draft
        @draft = @publication.repository.draft(path: @draft_path)
        add_breadcrumb(:drafts, find_publication_drafts_root_path)
      end
    end
  end
end
