# frozen_string_literal: true

module FaradayClient
  class RateLimit < Struct.new(:limit, :remaining, :resets_at, :resets_in)
    def self.from_response(response)
      info = new
      if response && response.respond_to?(:headers) && !response.headers.nil?
        info.limit = (response.headers['X-RateLimit-Limit'] || 1).to_i
        info.remaining = (response.headers['X-RateLimit-Remaining'] || 1).to_i
        info.resets_at = Time.at((response.headers['X-RateLimit-Reset'] || Time.now).to_i)
        info.resets_in = [(info.resets_at - Time.now).to_i, 0].max
      end

      info
    end
  end
end
