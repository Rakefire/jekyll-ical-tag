# encoding: utf-8
# frozen_string_literal: true

require "cgi"
require "api_cache"

module Jekyll
  class IcalTag
    class CalendarFetcher
      def initialize(url)
        @url = CGI.unescape(url)

        raise "No URL provided or in innapropriate form '#{url}'" unless is_valid_url?
      end

      def fetch
        puts "Fetching #{url}"
        @fetch ||= APICache.get(url)
      end

      private

      attr_reader :url

      def is_valid_url?
        !!(url =~ URI::regexp)
      end
    end
  end
end
