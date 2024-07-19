# frozen_string_literal: true

module Jekyll
  class IcalTag
    class CalendarLimiter
      def initialize(parser, options = {})
        @parser = parser
        @options = options
      end

      def events
        if options[:only] == :future
          now = Time.now
          parser.events.select do |event|
            event.dtstart.to_time >= now
          end
        elsif options[:only] == :past
          now = Time.now
          parser.events.select do |event|
            event.dtstart.to_time < now
          end
        elsif options[:reverse]
          parser.events.reverse
        elsif options[:after_date]
          parser.events.select do |event|
            event.dtstart.to_time >= options[:after_date]
          end
        elsif options[:before_date]
          parser.events.select do |event|
            event.dtstart.to_time < options[:before_date]
          end
        elsif options[:limit]
          parser.events.first(options[:limit])
        else
          parser.events
        end
      end

      private

      attr_reader :parser, :options
    end
  end
end
