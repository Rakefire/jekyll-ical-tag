# encoding: utf-8
# frozen_string_literal: true

require "uri"

module Jekyll
  class IcalTag
    class Event
      URL_REGEX = /(?:(?:https?|ftp):\/\/)(?:\S+(?::\S*)?@)?(?:(?!10(?:\.\d{1,3}){3})(?!127(?:\.\d{1,3}){3})(?!169\.254(?:\.\d{1,3}){2})(?!192\.168(?:\.\d{1,3}){2})(?!172\.(?:1[6-9]|2\d|3[0-1])(?:\.\d{1,3}){2})(?:[1-9]\d?|1\d\d|2[01]\d|22[0-3])(?:\.(?:1?\d{1,2}|2[0-4]\d|25[0-5])){2}(?:\.(?:[1-9]\d?|1\d\d|2[0-4]\d|25[0-4]))|(?:(?:[a-z\u00a1-\uffff0-9]+-?)*[a-z\u00a1-\uffff0-9]+)(?:\.(?:[a-z\u00a1-\uffff0-9]+-?)*[a-z\u00a1-\uffff0-9]+)*(?:\.(?:[a-z\u00a1-\uffff]{2,})))(?::\d{2,5})?(?:\/[^\s]*)?/
      extend Forwardable

      def initialize(event)
        @event = event
      end

      def_delegators :event, :dtstart, :dtend

      def all_properties
        @props ||= begin
            props = {}

            # RFC 5545 Properties
            event.class.properties.each do |property|
              props[property] = event.property(property)
            end

            # custom properties
            props = props.merge(event.custom_properties)

            props
          end
      end

      def simple_html_description
        @simple_html_description ||= begin
            description&.clone.tap do |d|
              description_urls.each do |url|
                d.force_encoding("UTF-8").gsub! url, %(<a href='#{url}'>#{url}</a>)
              end
            end
          end
      end

      def attendees
        attendee.map(&:to_s).map { |a| a.slice!("mailto:"); a }
      end

      def description_urls
        @description_urls ||= description.to_s.force_encoding("UTF-8").scan(URL_REGEX).to_a
      end

      private

      def_delegators :event, :description, :attendee
      attr_reader :event
    end
  end
end
