# frozen_string_literal: true

require "active_support"
require "icalendar"
require "icalendar/recurrence"

module Jekyll
  class IcalTag
    class CalendarParser
      def initialize(raw_feed, recurring_start_date:, recurring_end_date:)
        @raw_feed = raw_feed
        @recurring_start_date = recurring_start_date
        @recurring_end_date = recurring_end_date
      end

      def events
        @events ||= parsed_events.sort { |event1, event2| event1.dtstart <=> event2.dtstart }
                                 .map { |event| Jekyll::IcalTag::Event.new(event) }
      end

      private


      def parsed_events
        events = Icalendar::Event.parse(@raw_feed)
          .flat_map do |event|
            event
              .occurrences_between(@recurring_start_date, @recurring_end_date)
              .map do |occurrence|
                event.dup.tap do |e| # return a new event with the same attributes, but different start and end times
                  e.dtstart = occurrence.start_time
                  e.dtend = occurrence.end_time
                end
              end
          end.compact
        events
      end
    end
  end
end
