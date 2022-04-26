
module FaradayClient
  module Middleware
    class HTTPCacheMiddleware < Faraday::Middleware
      def call(request_env)
        @app.call(request_env).on_complete do |response_env|
          if headers = response_env[:response_headers]
            cache_control = parse(headers['cache-control'].to_s)
            cache_control.delete('max-age')
            cache_control.delete('s-maxage')
            cache_control['no-cache'] = true
            cache_control['must-revalidate'] = true
            headers['cache-control'] = dump(cache_control)

            vary = parse(headers['vary'].to_s)
            vary.delete('authorization')
            headers['vary'] = dump(vary)
          end
        end
      end

      private

      def dump(directives)
        directives.map do |k, v|
          if v == true
            k
          else
            "#{k}=#{v}"
          end
        end.join(', ')
      end

      def parse(header)
        directives = {}

        header.delete(' ').split(',').each do |part|
          next if part.empty?

          name, value = part.split('=', 2)
          directives[name.downcase] = (value || true) unless name.empty?
        end

        directives
      end
    end
  end
end
