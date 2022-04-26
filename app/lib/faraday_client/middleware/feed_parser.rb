# frozen_string_literal: true

require 'faraday'

module FaradayClient
  module Middleware
    class FeedParser < Faraday::Middleware
      def on_complete(env)
        if env[:response_headers]['content-type'] =~ /(\batom|\brss)/
          require 'rss'
          env[:body] = RSS::Parser.parse env[:body]
        end
      end
    end
  end
end
