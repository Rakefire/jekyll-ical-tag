require "api_cache"
require "active_support"
require "icalendar"

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

class CalendarLimiter
  def initialize(parser, options = {})
    @parser = parser
    @options = options
  end

  def events
    case
    when options[:only] == :future
      now = Time.now
      parser.events.select do |event|
        event.dtstart.to_time >= now
      end
    when options[:only] == :past
      now = Time.now
      parser.events.select do |event|
        event.dtstart.to_time < now
      end
    when options[:reverse]
      parser.events.reverse
    when options[:after_date]
      parser.events.select do |event|
        event.dtstart.to_time >= options[:after_date]
      end
    when options[:before_date]
      parser.events.select do |event|
        event.dtstart.to_time < options[:before_date]
      end
    else
      parser.events
    end
  end

  private

  attr_reader :parser, :options
end

module Jekyll
  class CalendarTag < Liquid::Block
    include Convertible

    def initialize(tag_name, markup, parse_context)
      super

      @markup = markup

      scan_attributes!
      set_reverse!
      set_url!
      set_only!
      set_before_date!
      set_after_date!
    end

    def render(context)
      context.registers[:ical] ||= Hash.new(0)

      result = []

      parser = CalendarParser.new(@url)
      parser = CalendarLimiter.new(parser, only: @only)
      parser = CalendarLimiter.new(parser, reverse: @reverse)
      parser = CalendarLimiter.new(parser, before_date: @before_date)
      parser = CalendarLimiter.new(parser, after_date: @after_date)

      events = parser.events
      length = events.length

      context.stack do
        events.each_with_index do |event, index|

          attendees = event.attendee.map(&:to_s).map {|a| a.slice!("mailto:"); a }

          context['event'] = {
            'index' => index,
            'uid' => event.uid,
            'summary' => event.summary,
            'description' => event.description,
            'location' => event.location,
            'url' => event.url&.to_s,
            'start_time' => event.dtstart&.to_time,
            'end_time' => event.dtend&.to_time,
            'attendees' => attendees,
          }

          context['forloop'] = {
            'name' => 'calendar',
            'length' => length,
            'index' => index + 1,
            'index0' => index,
            'rindex' => length - index,
            'rindex0' => length - index - 1,
            'first' => (index == 0),
            'last' => (index == length - 1)
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

    def scan_attributes!
      @attributes = {}
      @markup.scan(Liquid::TagAttributes) do |key, value|
        @attributes[key] = value
      end
    end

    def set_reverse!
      @reverse = @attributes['order'] == 'reverse'
    end

    def set_url!
      @url = @attributes['url']
      raise "No URL provided" unless @url
    end

    def set_only!
      only_future = @attributes["only_future"] == "true"
      only_past = @attributes["only_past"] == "true"

      raise "Set only_future OR only_past, not both" if only_future && only_past
      @only =
        case
        when only_future
          :future
        when only_past
          :past
        else
          :all
        end
    end

    def set_before_date!
      @before_date =
        begin
          if @attributes['before_date']
            Time.parse(@attributes['before_date'])
          end
        rescue => e
          nil
        end
    end

    def set_after_date!
      @after_date =
        begin
          if @attributes['after_date']
            Time.parse(@attributes['after_date'])
          end
        rescue => e
          nil
        end
    end
  end
end

Liquid::Template.register_tag('ical', Jekyll::CalendarTag)
