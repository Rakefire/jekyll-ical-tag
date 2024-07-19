require "spec_helper"

EXAMPLE_RAW_FEEDS =
  Dir
    .glob("spec/support/*.ics")
    .each_with_object({}) do |file, hash|
      hash[File.basename(file, ".ics").downcase.underscore.to_sym] = File.read(file)
    end
    .merge(
      empty: ""
    )

RSpec.describe Jekyll::IcalTag::CalendarFeedCoordinator do
  context "happy path" do
    let(:coordinator) { Jekyll::IcalTag::CalendarFeedCoordinator.new(url: "https://space.floern.com/launch.ics") }

    it "should not raise error" do
      expect { coordinator.events }.to_not raise_error
    end

    it "should return accurate event count" do
      expect(coordinator.events.count).to be > 0
    end

    it "should be able to parse all parse of each event" do
      coordinator.events.each do |event|
        expect { event.all_properties }.to_not raise_error
        expect { event.simple_html_description }.to_not raise_error
        expect { event.attendees }.to_not raise_error
        expect { event.description_urls }.to_not raise_error
      end
    end
  end

  context "with empty feed" do
    let(:fake_url) { "https://www.calendarfeed.com/feed.ics" }
    let(:mock_feed) { double(:mock_feed, fetch: EXAMPLE_RAW_FEEDS[:empty]) }

    before do
      allow(Jekyll::IcalTag::CalendarFetcher).to receive(:new).and_return(mock_feed)
    end

    let(:coordinator) { Jekyll::IcalTag::CalendarFeedCoordinator.new(url: fake_url) }

    it "should not raise error" do
      expect { coordinator.events }.to_not raise_error
    end

    it "should return accurate event count" do
      expect(coordinator.events.count).to eq(0)
    end
  end

  context "with basic feed" do
    let(:fake_url) { "https://www.calendarfeed.com/feed.ics" }
    let(:mock_feed) { double(:mock_feed, fetch: EXAMPLE_RAW_FEEDS[:basic]) }
    before { allow(Jekyll::IcalTag::CalendarFetcher).to receive(:new).and_return(mock_feed) }
    let(:coordinator) { Jekyll::IcalTag::CalendarFeedCoordinator.new(url: fake_url) }

    around do |example|
      travel_to Date.parse("2021-01-01") do
        example.run
      end
    end

    it "should not raise error" do
      expect {
        coordinator.events
      }.to_not raise_error
    end

    it "should return accurate event count" do
      expect(coordinator.events.count).to eq(66)
    end

    it "should be able to parse all parse of each event" do
      coordinator.events.each do |event|
        expect { event.all_properties }.to_not raise_error
        expect { event.simple_html_description }.to_not raise_error
        expect { event.attendees }.to_not raise_error
        expect { event.description_urls }.to_not raise_error
      end
    end

    it "should return dates from oldest to newest first" do
      first_date = coordinator.events.first.dtstart.to_date
      last_date = coordinator.events.last.dtstart.to_date

      expect(first_date).to be < last_date
    end

    describe "limit" do
      let(:coordinator) { Jekyll::IcalTag::CalendarFeedCoordinator.new(url: fake_url, limit: 5) }

      it "should return accurate event count" do
        expect(coordinator.events.count).to eq(5)
      end
    end

    describe "only future" do
      let(:coordinator) { Jekyll::IcalTag::CalendarFeedCoordinator.new(url: fake_url, only: :future) }

      it "should return accurate event count" do
        expect(coordinator.events.count).to eq(1)
      end
    end

    describe "only past" do
      let(:coordinator) { Jekyll::IcalTag::CalendarFeedCoordinator.new(url: fake_url, only: :past) }

      it "should return accurate event count" do
        expect(coordinator.events.count).to eq(65)
      end
    end

    describe "only all" do
      let(:coordinator) { Jekyll::IcalTag::CalendarFeedCoordinator.new(url: fake_url, only: :all) }

      it "should return accurate event count" do
        expect(coordinator.events.count).to eq(66)
      end
    end

    describe "before date" do
      let(:coordinator) { Jekyll::IcalTag::CalendarFeedCoordinator.new(url: fake_url, before_date: Date.parse("1/1/2020")) }

      it "should return accurate event count" do
        expect(coordinator.events.count).to eq(55)
      end
    end

    describe "after date" do
      let(:coordinator) { Jekyll::IcalTag::CalendarFeedCoordinator.new(url: fake_url, after_date: Date.parse("1/1/2020")) }

      it "should return accurate event count" do
        expect(coordinator.events.count).to eq(11)
      end
    end

    describe "reverse" do
      let(:coordinator) { Jekyll::IcalTag::CalendarFeedCoordinator.new(url: fake_url, reverse: true) }

      it "should return dates from oldest to newest first" do
        first_date = coordinator.events.first.dtstart.to_date
        last_date = coordinator.events.last.dtstart.to_date

        expect(first_date).to be > last_date
      end
    end
  end

  context "with italian feed" do
    let(:fake_url) { "https://www.calendarfeed.com/feed.ics" }
    let(:mock_feed) { double(:mock_feed, fetch: EXAMPLE_RAW_FEEDS[:italian]) }
    before { allow(Jekyll::IcalTag::CalendarFetcher).to receive(:new).and_return(mock_feed) }
    let(:coordinator) { Jekyll::IcalTag::CalendarFeedCoordinator.new(url: fake_url) }

    it "should not raise error" do
      expect {
        coordinator.events
      }.to_not raise_error
    end

    it "should return accurate event count" do
      expect(coordinator.events.count).to eq(10)
    end

    it "should be able to parse all parse of each event" do
      coordinator.events.each do |event|
        expect { event.all_properties }.to_not raise_error
        expect { event.simple_html_description }.to_not raise_error
        expect { event.attendees }.to_not raise_error
        expect { event.description_urls }.to_not raise_error
      end
    end

    it "selected outputs should always be strings" do
      coordinator.events.each do |event|
        expect(event.simple_html_description.to_s).to be_a String
        expect(event.description.to_s).to be_a String
        event.all_properties.each do |property, value|
          expect(value).to be_a(Time)
            .or be_a(Date)
            .or be_a(String)
            .or be_a(NilClass)
        end
      end
    end
  end

  context "with sesh feed" do
    let(:fake_url) { "https://www.calendarfeed.com/feed.ics" }
    let(:mock_feed) { double(:mock_feed, fetch: EXAMPLE_RAW_FEEDS[:sesh]) }
    before { allow(Jekyll::IcalTag::CalendarFetcher).to receive(:new).and_return(mock_feed) }
    let(:coordinator) { Jekyll::IcalTag::CalendarFeedCoordinator.new(url: fake_url) }

    it "should return accurate event count" do
      expect(coordinator.events.count).to eq(3)
    end

    describe "reverse" do
      let(:coordinator) { Jekyll::IcalTag::CalendarFeedCoordinator.new(url: fake_url, reverse: reverse) }

      context "when reversed" do
        let(:reverse) { true }

        it "should return dates from oldest to newest first" do
          first_date = coordinator.events.first.dtstart.to_date
          last_date = coordinator.events.last.dtstart.to_date

          expect(first_date).to be > last_date
        end
      end

      context "when not reversed" do
        let(:reverse) { false }

        it "should return dates from oldest to newest first" do
          first_date = coordinator.events.first.dtstart.to_date
          last_date = coordinator.events.last.dtstart.to_date

          expect(first_date).to be < last_date
        end
      end
    end
  end

  context "with recurrent events" do
    let(:fake_url) { "https://www.calendarfeed.com/feed.ics"}
    let(:mock_feed) { double(:mock_feed, fetch: EXAMPLE_RAW_FEEDS[:recurring])}
    before { allow(Jekyll::IcalTag::CalendarFetcher).to receive(:new).and_return(mock_feed) }
    let(:coordinator) { Jekyll::IcalTag::CalendarFeedCoordinator.new(url: fake_url) }

    it "should return accurate event count" do
      expect(coordinator.events.count).to eq(54)
    end

    it "should not have duplicate events" do
      start_dates = coordinator.events.map(&:dtstart)
      expect(start_dates.count).to eq(start_dates.uniq.count)

      end_dates = coordinator.events.map(&:dtend)
      expect(end_dates.count).to eq(end_dates.uniq.count)
    end

    context "with recurring_start_date and recurring_end_date" do
      let(:recurring_start_date) { Date.parse("July 1, 2024") }
      let(:recurring_end_date) { Date.parse("July 30, 2024") }
      let(:coordinator) { Jekyll::IcalTag::CalendarFeedCoordinator.new(url: fake_url, recurring_start_date: recurring_start_date, recurring_end_date: recurring_end_date) }

      it "should return accurate event count" do
        expect(coordinator.events.count).to eq(6)
      end
    end
  end
end
