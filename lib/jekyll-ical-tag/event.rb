# frozen_string_literal: true

require "uri"
require "active_support"
require "active_support/core_ext/object/blank"

module Jekyll
  class IcalTag
    class Event
      URL_REGEX = /
        (?:(?:https?|ftp):\/\/) # Allowable schemes
        (?:\S+(?::\S*)?@)?      # username:password, which is optional
        (?:                     # Domain part follows; non-capturing
          # These IP addresses are valid domain values
          (?!10(?:\.\d{1,3}){3})
          (?!127(?:\.\d{1,3}){3})
          (?!169\.254(?:\.\d{1,3}){2})
          (?!192\.168(?:\.\d{1,3}){2})
          (?!172\.(?:1[6-9]|2\d|3[0-1])(?:\.\d{1,3}){2})
          (?:[1-9]\d?|1\d\d|2[01]\d|22[0-3])
          (?:\.(?:1?\d{1,2}|2[0-4]\d|25[0-5])){2}
          (?:\.(?:[1-9]\d?|1\d\d|2[0-4]\d|25[0-4]))
          |
          (?:(?:[a-z\u00a1-\uffff0-9]+-?)*[a-z\u00a1-\uffff0-9]+)
          (?:\.(?:[a-z\u00a1-\uffff0-9]+-?)*[a-z\u00a1-\uffff0-9]+)*
          (?:\.(?:[a-z\u00a1-\uffff]{2,}))
        )
        (?::\d{2,5})?           # Optional port number
        (?:\/[^\s"]*)?          # Anything that is not a space or a double quote
        /x

      def initialize(ical_event)
        @ical_event = ical_event
        setup_all_properties!
        setup_property_accessor_methods!
      end

      attr_reader :all_properties

      def simple_html_description
        @simple_html_description ||= description.clone.tap do |description|
          description_urls.each do |url|
            description.gsub! url, %(<a href='#{url}'>#{url}</a>)
          end
        end
      end

      def attendees
        ical_event.attendee.map(&:to_s).map { |a|
          a.slice!("mailto:")
          a
        }
      end

      def description_urls
        return [] unless description

        @description_urls ||= description.scan(URL_REGEX).to_a
      end

      private

      attr_reader :ical_event

      def setup_all_properties!
        @all_properties ||= begin
          props = {}

          # RFC 5545 Properties
          ical_event.class.properties.each do |property|
            props[property] = ical_event.property(property)
          end

          # custom properties
          props = props.merge(ical_event.custom_properties)

          # Ensure all arrays get flattened to utf8 encoded strings
          # Ensure all event values are utf8 encoded strings
          # Ensure times (from dates)
          # Ensure present
          props.transform_values! do |value|
            new_value =
              case value
              when Array, Icalendar::Values::Helpers::Array
                value.join("\n").force_encoding("UTF-8")
              when String, Icalendar::Values::Text
                value.force_encoding("UTF-8")
              when Date, Icalendar::Values::DateTime
                value.to_time
              when Icalendar::Values::Uri
                value.to_s
              else
                value
              end

            new_value.presence
          end

          props
        end
      end

      def setup_property_accessor_methods!
        all_properties.each do |prop, value|
          define_singleton_method prop do
            all_properties[prop]
          end
        end
      end
    end
  end
end
