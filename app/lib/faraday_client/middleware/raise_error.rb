# frozen_string_literal: true

require_relative '../error.rb'

module FaradayClient
  module Middleware
    class RaiseError < Faraday::Response::Middleware
      def on_complete(response)
        if error = FaradayClient::Error.from_response(response)
          raise error
        end
      end
    end
  end
end
