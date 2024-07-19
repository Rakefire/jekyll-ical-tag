# encoding: utf-8
# frozen_string_literal: true

require "jekyll"
require "jekyll-ical-tag/version"

module Jekyll
  class IcalTag < Liquid::Block
    require_relative "jekyll-ical-tag/calendar_feed_coordinator"
    require_relative "jekyll-ical-tag/calendar_fetcher"
    require_relative "jekyll-ical-tag/calendar_limiter"
    require_relative "jekyll-ical-tag/calendar_parser"
    require_relative "jekyll-ical-tag/event"

    include Convertible

    def initialize(tag_name, markup, parse_context)
      super
      @markup = markup
      @attributes = {}

      scan_attributes!
      set_limit!
      set_reverse!
      set_only!
    end

    def render(context)
      self.context = context
      context.registers[:ical] ||= Hash.new(0)

      set_recurring_dates!

      result = []

      context.stack do
        url = dereferenced_liquid_val("url")
        before_date = before_date_from
        after_date = after_date_from

        calendar_feed_coordinator = CalendarFeedCoordinator.new(
          url: url,
          only: @only,
          reverse: @reverse,
          before_date: before_date,
          after_date: after_date,
          limit: @limit,
          recurring_start_date: @recurring_start_date,
          recurring_end_date: @recurring_end_date
        )
        events = calendar_feed_coordinator.events
        event_count = events.length

        events.each_with_index do |event, index|
          # Init
          context["event"] = {}

          # Jekyll helper variables
          context["event"]["index"] = index

          # RFC 5545 conformant and custom properties.
          context["event"].merge!(event.all_properties)

          # Supported but non-standard attributes.
          context["event"]["attendees"] = event.attendees
          context["event"]["simple_html_description"] = event.simple_html_description

          # Overridden values
          context["event"]["url"] ||= event.description_urls.first

          # Deprecated attribute names.
          context["event"]["end_time"] = context["event"]["dtend"]
          context["event"]["start_time"] = context["event"]["dtstart"]

          context["forloop"] = {
            "name" => "ical",
            "length" => event_count,
            "index" => index + 1,
            "index0" => index,
            "rindex" => event_count - index,
            "rindex0" => event_count - index - 1,
            "first" => (index == 0),
            "last" => (index == event_count - 1),
          }

          result << nodelist.map do |n|
            if n.respond_to? :render
              n.render(context)
            else
              n
            end
          end.join
        end
      end

      result
    end

    private

    attr_accessor :context

    def after_date_from
      safely_cast_to_time(
        dereferenced_liquid_val("after_date")
      )
    end

    def before_date_from
      safely_cast_to_time(
        dereferenced_liquid_val("before_date")
      )
    end

    def safely_cast_to_time(val)
      case val
      when String
        Time.parse(val)
      when Date, DateTime, Time
        val
      when NilClass
        # Do nothing
      else
        raise "Cannot cast to Time: #{val}"
      end
    end

    def dereferenced_liquid_val(variable_name)
      raw_value = @attributes[variable_name]

      context.key?(raw_value) ? context[raw_value] : raw_value
    end

    def scan_attributes!
      @markup.scan(Liquid::TagAttributes) do |key, value|
        @attributes[key] = value
      end
    end

    def set_limit!
      @limit = nil
      @limit = @attributes["limit"].to_i if @attributes["limit"]
    end

    def set_reverse!
      @reverse = @attributes["reverse"] == "true"
    end

    def set_only!
      only_future = @attributes["only_future"] == "true"
      only_past = @attributes["only_past"] == "true"

      raise "Set only_future OR only_past, not both" if only_future && only_past

      @only =
        if only_future
          :future
        elsif only_past
          :past
        else
          :all
        end
    end

    def set_recurring_dates!
      @recurring_end_date =
        safely_cast_to_time(
         dereferenced_liquid_val("recurring_end_date")
        )

      @recurring_start_date =
        safely_cast_to_time(
         dereferenced_liquid_val("recurring_start_date")
        )
    end
  end
end

Liquid::Template.register_tag("ical", Jekyll::IcalTag)
