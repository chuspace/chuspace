# frozen_string_literal: true

module Posts
  class SnippetsController < BaseController
    layout false

    def index
      authorize! @post

      stringio = Zip::OutputStream::write_buffer do |zio|
        @post.markdown_doc.snippets.each_with_index do |snippet, index|
          extname = Language.find_by_name(snippet.language)&.extensions&.first || '.txt'
          zio.put_next_entry("snippet#{index}#{extname}")
          zio.write(snippet.content)
        end
      end

      stringio.rewind
      send_data stringio.read, filename: 'code-snippets.zip', disposition: 'attachment', type: 'application/zip'
    end

    def show
      authorize! @post

      snippet = @post.markdown_doc.snippets.find { |snippet| snippet.id == params[:id] }
      extname = Language.find_by_name(snippet.language) || 'txt'

      send_data StringIO.new(snippet.content), filename: "code-snippet-#{params[:id]}.#{extname}"
    end
  end
end
