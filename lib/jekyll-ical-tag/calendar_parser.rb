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
        @events ||=
          parsed_events
            .sort_by(&:dtstart)
            .map { |event| Jekyll::IcalTag::Event.new(event) }
      end

      private

      def parsed_events
        events = Icalendar::Event.parse(@raw_feed)

        recurring_events =
          events
            .select { |event| event.rrule.present? }
            .flat_map do |event|
              event
                .occurrences_between(@recurring_start_date, @recurring_end_date)
                .map { |occurrence| build_occurance_event(event, occurrence) }
            end
            .compact

        events.concat(recurring_events)
      end

      # return a new event with the same attributes, but different start and end times
      def build_occurance_event(event, occurrence)
        return if is_duplicate_event?(event, occurrence)

        event.dup.tap do |e|
          e.dtstart = occurrence.start_time
          e.dtend = occurrence.end_time
        end
      end

      def is_duplicate_event?(event, occurrence)
        event.dtstart.to_time == occurrence.start_time.to_time ||
          event.dtend.to_time == occurrence.end_time.to_time
      end
    end
  end
end
