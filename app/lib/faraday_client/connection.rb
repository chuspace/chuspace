# frozen_string_literal: true

require_relative 'middleware/follow_redirects'
require_relative 'middleware/raise_error'
require_relative 'middleware/feed_parser'

module FaradayClient
  module Connection
    MIDDLEWARE = Faraday::RackBuilder.new do |builder|
      builder.use Faraday::Request::Retry, exceptions: [FaradayClient::ServerError]
      builder.use FaradayClient::Middleware::FollowRedirects
      builder.use FaradayClient::Middleware::RaiseError
      unless Rails.env.production?
        builder.response :logger, nil, { headers: true, bodies: true }
      end
      builder.use FaradayClient::Middleware::FeedParser
      builder.use Faraday::HttpCache, serializer: Marshal, shared_cache: false, store: Rails.cache, logger: Rails.logger
      builder.adapter Faraday.default_adapter
    end

    # Header keys that can be passed in options hash to {#get},{#head}
    CONVENIENCE_HEADERS = Set.new([:accept, :content_type])

    # Make a HTTP GET request
    #
    # @param url [String] The path, relative to {#api_endpoint}
    # @param options [Hash] Query and header params for request
    # @return [Sawyer::Resource]
    def get(url, options = {})
      request :get, url, parse_query_and_convenience_headers(options)
    end

    # Make a HTTP POST request
    #
    # @param url [String] The path, relative to {#api_endpoint}
    # @param options [Hash] Body and header params for request
    # @return [Sawyer::Resource]
    def post(url, options = {})
      request :post, url, options
    end

    # Make a HTTP PUT request
    #
    # @param url [String] The path, relative to {#api_endpoint}
    # @param options [Hash] Body and header params for request
    # @return [Sawyer::Resource]
    def put(url, options = {})
      request :put, url, options
    end

    # Make a HTTP PATCH request
    #
    # @param url [String] The path, relative to {#api_endpoint}
    # @param options [Hash] Body and header params for request
    # @return [Sawyer::Resource]
    def patch(url, options = {})
      request :patch, url, options
    end

    # Make a HTTP DELETE request
    #
    # @param url [String] The path, relative to {#api_endpoint}
    # @param options [Hash] Query and header params for request
    # @return [Sawyer::Resource]
    def delete(url, options = {})
      request :delete, url, options
    end

    # Make a HTTP HEAD request
    #
    # @param url [String] The path, relative to {#api_endpoint}
    # @param options [Hash] Query and header params for request
    # @return [Sawyer::Resource]
    def head(url, options = {})
      request :head, url, parse_query_and_convenience_headers(options)
    end

    # Make one or more HTTP GET requests, optionally fetching
    # the next page of results from URL in Link response header based
    # on value in {#auto_paginate}.
    #
    # @param url [String] The path, relative to {#api_endpoint}
    # @param options [Hash] Query and header params for request
    # @param block [Block] Block to perform the data concatination of the
    #   multiple requests. The block is called with two parameters, the first
    #   contains the contents of the requests so far and the second parameter
    #   contains the latest response.
    # @return [Sawyer::Resource]
    def paginate(url, options = {}, &block)
      opts = parse_query_and_convenience_headers(options)
      if @auto_paginate || @per_page
        opts[:query][:per_page] ||= @per_page || (@auto_paginate ? 100 : nil)
      end

      data = request(:get, url, opts.dup)

      if @auto_paginate
        while @last_response.rels[:next] && rate_limit.remaining > 0
          @last_response = @last_response.rels[:next].get(headers: opts[:headers])
          if block_given?
            yield(data, @last_response)
          else
            data.concat(@last_response.data) if @last_response.data.is_a?(Array)
          end
        end

      end

      data
    end

    # Hypermedia agent for the API
    # @return [Sawyer::Agent]
    def agent
      @agent ||= Sawyer::Agent.new(endpoint, sawyer_options) do |http|
        http.headers[:accept] = default_media_type
        http.headers[:content_type] = 'application/json'
        http.headers[:user_agent] = user_agent
        http.headers['Sudo'] = @sudo if @sudo

        case name
        when 'github', 'github_enterprise'
          http.authorization 'token', @access_token
        when 'gitlab', 'gitlab_foss'
          http.authorization 'Bearer', @access_token
        when 'chuspace', 'gitea'
          http.authorization 'token', @access_token
        end

        if @basic_auth
          username = Rails.application.credentials.storage[:chuspace].dig(:username)
          password = Rails.application.credentials.storage[:chuspace].dig(:password)
          http.basic_auth username, password
        end
      end
    end

    # Fetch the root resource for the API
    # @return [Sawyer::Resource]
    def root
      get '/'
    end

    # Response for last HTTP request
    # @return [Sawyer::Response]
    def last_response
      @last_response if defined? @last_response
    end

    private

    def user_agent
      'Chuspace'.freeze
    end

    def reset_agent
      @agent = nil
    end

    def request(method, path, data, options = {})
      if data.is_a?(Hash)
        options[:query]   = data.delete(:query) || {}
        options[:headers] = data.delete(:headers) || {}
        if accept = data.delete(:accept)
          options[:headers][:accept] = accept
        end
      end

      @last_response = response = agent.call(method, Addressable::URI.parse(path.to_s).normalize.to_s, data, options)
      response.data
    rescue FaradayClient::Error => error
      @last_response = nil
      raise error
    end

    # Executes the request, checking if it was successful
    # @return [Boolean] True on success, false otherwise
    def boolean_from_response(method, path, options = {})
      request(method, path, options)
      [201, 202, 204].include? @last_response.status
    rescue FaradayClient::NotFound
      false
    end

    def default_media_type
      'application/json'.freeze
    end

    def sawyer_options
      opts = {
        links_parser: Sawyer::LinkParsers::Simple.new
      }

      conn_opts = {
        headers: {
          accept: default_media_type,
          user_agent: user_agent
        },
        ssl: { verify: false }
      }

      conn_opts[:builder] = MIDDLEWARE
      opts[:faraday] = Faraday.new(conn_opts)
      opts
    end

    def parse_query_and_convenience_headers(options)
      options = options.dup
      headers = options.delete(:headers) { Hash.new }
      CONVENIENCE_HEADERS.each do |h|
        if header = options.delete(h)
          headers[h] = header
        end
      end
      query = options.delete(:query)
      opts = { query: options }
      opts[:query].merge!(query) if query && query.is_a?(Hash)
      opts[:headers] = headers unless headers.empty?

      opts
    end
  end
end