# frozen_string_literal: true

module Publications
  module Drafts
    class DiffsController < BaseController
      layout 'blank'

      def new
        @diff = Diffy::Diff.new("#{@draft.decoded_content}\n", "#{@draft.local_content.value}\n", Diffy::Diff.default_options).to_s(:text)

        respond_to do |format|
          format.html
          format.turbo_stream
        end
      end
    end
  end
end
