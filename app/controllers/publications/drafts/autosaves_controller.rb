# frozen_string_literal: true

module Publications
  module Drafts
    class AutosavesController < BaseController
      layout 'blank'

      def create
        authorize! @draft, to: :autosave?

        EditingLock.transaction do
          lock = @publication.editing_locks.find_or_initialize_by(
            blob_path: @draft.path,
            owner: Current.user
          )

          lock.assign_attributes(expires_at: EditingLock::DEFAULT_EXPIRES_AT, **autosave_params)

          if lock.save
            render turbo_stream: turbo_stream.update(helpers.dom_id(@draft, :actions), partial: 'publications/drafts/actions', locals: { publication: @publication, draft: @draft })
          else
            head :ok
          end
        end
      end

      private

      def autosave_params
        params.require(:draft).permit(:content)
      end
    end
  end
end
