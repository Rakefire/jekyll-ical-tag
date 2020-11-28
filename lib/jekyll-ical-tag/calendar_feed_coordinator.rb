# encoding: utf-8
# frozen_string_literal: true

require "cgi"
require "api_cache"

module Jekyll
  class IcalTag
    class CalendarFeedCoordinator
      def initialize(url:, only: nil, reverse: nil, before_date: nil, after_date: nil, limit: nil)
        @url = url
        @only = only
        @reverse = reverse
        @before_date = before_date
        @after_date = after_date
        @limit = limit
      end

      def events
        parser.events
      end

      private

      attr_reader :url, :only, :reverse, :before_date, :after_date, :limit

      def raw_ical
        @raw_ical ||= CalendarFetcher.new(url).fetch
      end

      def parser
        @parser ||= begin
          parser = CalendarParser.new(raw_ical)
          parser = CalendarLimiter.new(parser, only: only)
          parser = CalendarLimiter.new(parser, reverse: reverse)
          parser = CalendarLimiter.new(parser, before_date: before_date)
          parser = CalendarLimiter.new(parser, after_date: after_date)
          CalendarLimiter.new(parser, limit: limit)
        end
      end
    end
  end
end
