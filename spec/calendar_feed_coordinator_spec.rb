require "spec_helper"

EXAMPLE_RAW_FEEDS = {
  empty: "",
  basic: File.read("spec/support/basic.ics"),
  italian: File.read("spec/support/serenoregis.ics")
}

describe Jekyll::IcalTag::CalendarFeedCoordinator do
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
    let(:fake_url) { "https://www.calendarfeed.com/feed.ics"}
    let(:mock_feed) { double(:mock_feed, fetch: EXAMPLE_RAW_FEEDS[:empty])}

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
    let(:fake_url) { "https://www.calendarfeed.com/feed.ics"}
    let(:mock_feed) { double(:mock_feed, fetch: EXAMPLE_RAW_FEEDS[:basic])}
    before { allow(Jekyll::IcalTag::CalendarFetcher).to receive(:new).and_return(mock_feed) }
    let(:coordinator) { Jekyll::IcalTag::CalendarFeedCoordinator.new(url: fake_url) }

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
    let(:fake_url) { "https://www.calendarfeed.com/feed.ics"}
    let(:mock_feed) { double(:mock_feed, fetch: EXAMPLE_RAW_FEEDS[:italian])}
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
  end
end