# encoding: utf-8
# frozen_string_literal: true

module Jekyll
  class IcalTag
    class CalendarFeedCoordinator
      def initialize(url:, only: nil, reverse: nil, before_date: nil, after_date: nil, limit: nil, recurring_start_date: nil, recurring_end_date: nil)
        @url = url
        @only = only
        @reverse = reverse
        @before_date = before_date
        @after_date = after_date
        @limit = limit
        @recurring_start_date = recurring_start_date
        @recurring_end_date = recurring_end_date
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
          parser = CalendarParser.new(raw_ical, recurring_start_date: recurring_start_date, recurring_end_date: recurring_end_date)
          parser = CalendarLimiter.new(parser, only: only)
          parser = CalendarLimiter.new(parser, reverse: reverse)
          parser = CalendarLimiter.new(parser, before_date: before_date)
          parser = CalendarLimiter.new(parser, after_date: after_date)
          CalendarLimiter.new(parser, limit: limit)
        end
      end

      def recurring_start_date
        @recurring_start_date || after_date || Date.today
      end

      def recurring_end_date
        @recurring_end_date || before_date || (recurring_start_date + 1.year)
      end
    end
  end
end
