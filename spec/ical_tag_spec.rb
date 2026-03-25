require "spec_helper"

BASIC_RAW_FEED = File.read("spec/support/basic.ics")
EMPTY_RAW_FEED = ""

RSpec.describe Jekyll::IcalTag do
  let(:fake_url) { "https://www.calendarfeed.com/feed.ics" }

  def render_template(template_string)
    template = Liquid::Template.parse(template_string)
    template.render({}, registers: {ical: Hash.new(0)})
  end

  def stub_feed(raw_feed)
    mock_feed = double(:mock_feed, fetch: raw_feed)
    allow(Jekyll::IcalTag::CalendarFetcher).to receive(:new).and_return(mock_feed)
  end

  context "with events" do
    before { stub_feed(BASIC_RAW_FEED) }

    around do |example|
      travel_to Date.parse("2021-01-01") do
        example.run
      end
    end

    it "renders the block body for each event" do
      output = render_template(
        '{% ical url: "https://www.calendarfeed.com/feed.ics" limit: 3 %}' \
        "{{ event.summary }}|" \
        "{% endical %}"
      )
      summaries = output.split("|").map(&:strip).reject(&:empty?)
      expect(summaries.length).to eq(3)
      expect(summaries).to all(be_a(String))
    end

    it "provides forloop variables" do
      output = render_template(
        '{% ical url: "https://www.calendarfeed.com/feed.ics" limit: 2 %}' \
        "{{ forloop.index }}-{{ forloop.first }}-{{ forloop.last }}|" \
        "{% endical %}"
      )
      entries = output.split("|").map(&:strip).reject(&:empty?)
      expect(entries[0]).to eq("1-true-false")
      expect(entries[1]).to eq("2-false-true")
    end

    it "does not render the empty block when events exist" do
      output = render_template(
        '{% ical url: "https://www.calendarfeed.com/feed.ics" limit: 2 %}' \
        "EVENT" \
        "{% empty %}" \
        "NO EVENTS" \
        "{% endical %}"
      )
      expect(output).to include("EVENT")
      expect(output).not_to include("NO EVENTS")
    end
  end

  context "with no events" do
    before { stub_feed(EMPTY_RAW_FEED) }

    it "renders nothing when there is no empty block" do
      output = render_template(
        '{% ical url: "https://www.calendarfeed.com/feed.ics" %}' \
        "{{ event.summary }}" \
        "{% endical %}"
      )
      expect(output.strip).to eq("")
    end

    it "renders the empty block content" do
      output = render_template(
        '{% ical url: "https://www.calendarfeed.com/feed.ics" %}' \
        "{{ event.summary }}" \
        "{% empty %}" \
        "No upcoming events" \
        "{% endical %}"
      )
      expect(output.strip).to eq("No upcoming events")
    end

    it "renders the empty block with HTML content" do
      output = render_template(
        '{% ical url: "https://www.calendarfeed.com/feed.ics" %}' \
        '<div class="event">{{ event.summary }}</div>' \
        "{% empty %}" \
        '<p class="no-events">Nothing scheduled</p>' \
        "{% endical %}"
      )
      expect(output.strip).to eq('<p class="no-events">Nothing scheduled</p>')
    end
  end
end
