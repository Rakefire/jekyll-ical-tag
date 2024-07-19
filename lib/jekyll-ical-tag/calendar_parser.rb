# frozen_string_literal: true

require "active_support"
require "icalendar"

module Jekyll
  class IcalTag
    class CalendarParser
      def initialize(raw_feed)
        @raw_feed = raw_feed
      end

      def events
        @events ||= parsed_feed.sort_by(&:dtstart)
          .map { |event| Jekyll::IcalTag::Event.new(event) }
      end

      private

<<<<<<< Updated upstream
      def parsed_feed
        Icalendar::Event.parse(@raw_feed)
=======
      def parsed_events
        events = Icalendar::Event.parse(@raw_feed)

        recurring_events =
          events.flat_map do |event|
            next unless event.rrule.present?

            event
              .occurrences_between(@recurring_start_date, @recurring_end_date).drop(1)
              .map do |occurrence|
                event.dup.tap do |e| # return a new event with the same attributes, but different start and end times
                  e.dtstart = occurrence.start_time
                  e.dtend = occurrence.end_time
                end
              end
          end
          .compact

        events.concat(recurring_events)
>>>>>>> Stashed changes
      end
    end
  end
end
