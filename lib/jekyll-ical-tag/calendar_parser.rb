# encoding: utf-8
# frozen_string_literal: true

require "api_cache"
require "active_support"
require "icalendar"

module Jekyll
  class IcalTag
    class CalendarParser
      def initialize(raw_feed)
        @raw_feed = raw_feed
      end

      def events
        @events ||= parsed_feed.sort { |event1, event2| event1.dtstart <=> event2.dtstart }
                               .map { |event| Jekyll::IcalTag::Event.new(event) }
      end

      private

      def parsed_feed
        Icalendar::Event.parse(@raw_feed)
      end
    end
  end
end
