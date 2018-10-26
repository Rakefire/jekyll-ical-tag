# frozen_string_literal: true

require "api_cache"
require "active_support"
require "icalendar"

module Jekyll
  class IcalTag
    class CalendarParser
      def initialize(url)
        @url = URI.unescape(url)
      end

      def events
        @events ||= Icalendar::Event.parse(ics_feed).sort { |e1, e2| e1.dtstart <=> e2.dtstart }
      end

      private

      def ics_feed
        @ics_feed ||= APICache.get(@url)
      end
    end
  end
end
