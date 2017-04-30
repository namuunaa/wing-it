require "spec_helper"

describe AlexaInterfaceHelper do
  describe "#call" do
    it "returns an array of hashes" do
      response = helper.call({})
      expect(response).to be_a_kind_of(Array)
      expect(response[0]).to be_a_kind_of(Hash)
    end

    xit "makes an API call" do
    end

    it "returns events that are occurring today" do
      response = helper.call({})
      # Check "start_time" for each event in the array
        # Convert from string to Datetime obj
        # compare date part with Datetime.today
      response.each do |event|
        event_start = DateTime.parse(event["start_time"])
        expect(event_start.strftime("%F")).to eq(Date.today.strftime("%F"))
      end
    end
  end

  describe '#select_not_started' do
    let(:response) do
      select_not_started(helper.call)
    end

    it 'only selects events whose start time is after the current time' do
      response.each do |event|
        event_start = Time.parse(event["start_time"])
        expect(event_start).to be > Time.now
      end
    end

    it 'includes all-day events in the output' do
      expect(select_not_started([{"watching_count"=>nil, "olson_path"=>"America/Los_Angeles", "calendar_count"=>nil, "comment_count"=>nil, "region_abbr"=>"CA", "postal_code"=>"94117", "going_count"=>nil, "all_day"=>"2", "latitude"=>"37.7679471", "groups"=>nil, "url"=>"http://sanfrancisco.eventful.com/events/drama-b-ce12nd-cm25th-/E0-001-098365434-7?utm_source=apis&utm_medium=apim&utm_campaign=apic", "id"=>"E0-001-098365434-7", "privacy"=>"1", "city_name"=>"San Francisco", "link_count"=>nil, "longitude"=>"-122.4466472", "country_name"=>"United States", "country_abbr"=>"USA", "region_name"=>"California", "start_time"=>"2017-04-30 00:00:00", "tz_id"=>nil, "description"=>nil, "modified"=>"2016-12-06 06:04:46", "venue_display"=>"1", "tz_country"=>nil, "performers"=>{"performer"=>{"creator"=>"Drama5", "linker"=>"evdb", "name"=>"Drama B", "url"=>"http://eventful.com/performers/drama-b-/P0-001-000120213-6?utm_source=apis&utm_medium=apim&utm_campaign=apic", "id"=>"P0-001-000120213-6", "short_bio"=>"Best Rapper"}}, "title"=>"Drama B - CE1/2nd to CM2/5th", "venue_address"=>"755 Ashbury St", "geocode_type"=>"EVDB Geocoder", "tz_olson_path"=>nil, "recur_string"=>nil, "calendars"=>nil, "owner"=>"evdb", "going"=>nil, "country_abbr2"=>"US", "image"=>{"small"=>{"width"=>"48", "url"=>"http://s3.evcdn.com/images/small/I0-001/000/870/918-8.jpeg_/drama-b-18.jpeg", "height"=>"48"}, "width"=>"48", "caption"=>nil, "medium"=>{"width"=>"128", "url"=>"http://s3.evcdn.com/images/medium/I0-001/000/870/918-8.jpeg_/drama-b-18.jpeg", "height"=>"128"}, "url"=>"http://s3.evcdn.com/images/small/I0-001/000/870/918-8.jpeg_/drama-b-18.jpeg", "thumb"=>{"width"=>"48", "url"=>"http://s3.evcdn.com/images/thumb/I0-001/000/870/918-8.jpeg_/drama-b-18.jpeg", "height"=>"48"}, "height"=>"48"}, "created"=>"2016-12-06 06:04:46", "venue_id"=>"V0-001-006209264-6", "tz_city"=>nil, "stop_time"=>"2017-06-06 00:00:00", "venue_name"=>"Ashbury Campus", "venue_url"=>"http://sanfrancisco.eventful.com/venues/ashbury-campus-/V0-001-006209264-6?utm_source=apis&utm_medium=apim&utm_campaign=apic"}]).length).not_to be 0
    end
  end

  describe '#pick10' do
    let(:response) do
      helper.call
    end

    it 'outputs an array with a length of 10' do
      expect(pick10(response).length).not_to be > 10
    end

    it 'outputs an array even if input array contains less than 10 events' do
      expect(pick10(response[0..3]).length).to be 4
    end
  end

  describe '#pick1' do
    let(:response) do
      pick10(helper.call)
    end

    it 'outputs a hash' do
      expect(pick1(response)).to be_a_kind_of(Hash)
    end

    it 'outputs nil if it takes an empty array' do
      expect(pick1([])).to be nil
    end
  end

  describe '#format_speech_for_alexa' do
    let(:response) do
      AlexaRubykit::Response.new
    end

    let(:event) do
      {'title' => 'Hamilton', 'venue_name' => 'DBC', 'start_time' => '2017-04-29 18:00'}
    end

    it "does not include an @speech attribute before the add_speech method is run" do
      expect(response.speech).to be nil
    end

    it "adds an @speech attribute after the add_speech method is run" do
      format_speech_for_alexa(response, event)
      expect(response.speech[:text]).to eq("Hamilton is happening at DBC starting at  6:00 PM")
    end
  end

  describe '#format_html_text_to_string' do
    let(:html_text) do
      "<br>Souvenir is his band&#39;s most expansive album to date, dishing up everything from the West Coast<br>country-rock of &quot;California&quot; to the front-porch folk of &quot;Mama Sunshine, Daddy&#39;s Rain.&quot;"
    end

    it 'removes html tags and formats into alexa writable string' do
      alexa_text = format_html_text_to_string(html_text)
      expect(alexa_text).to eq("\nSouvenir is his band's most expansive album to date, dishing up everything from the West Coast\ncountry-rock of \"California\" to the front-porch folk of \"Mama Sunshine, Daddy's Rain.\"")
    end

    it 'clips descriptions longer than 500 characters down to 500 + ...' do
      desc = "a" * 600
      expect(format_html_text_to_string(desc).length).to eq(503)
      expect(format_html_text_to_string(desc)[(-3..-1)]).to eq("...")
    end
  end

  describe '#find_formatted_description' do
    it 'returns default description if the event has no description' do
      event_hash = {}
      expect(find_formatted_description(event_hash)).to eq('We don\'t have any details on this event')
    end

    it 'formats the string correctly if there is a description' do
      event_hash = {'description' => "<br>Souvenir is his band&#39;s most expansive album to date, dishing up everything from the West Coast<br>country-rock of &quot;California&quot; to the front-porch folk of &quot;Mama Sunshine, Daddy&#39;s Rain.&quot;"}
      expect(find_formatted_description(event_hash)).to eq("\nSouvenir is his band's most expansive album to date, dishing up everything from the West Coast\ncountry-rock of \"California\" to the front-porch folk of \"Mama Sunshine, Daddy's Rain.\"")
    end
  end

  describe '#generate_single_event_text_for_card' do
    let(:event) do
      { 'title' => 'Hamilton', 'venue_name' => 'DBC', 'start_time' => '2017-04-29 18:00', 'url' => 'http://www.hamiltonevent.com' }
    end

    it 'formats a string with the event details' do
      expect(generate_single_event_text_for_card(event)).to eq("Event: Hamilton \n Venue: DBC \n Time:  6:00 PM \n Description: We don\'t have any details on this event \n More Info: http://www.hamiltonevent.com")
    end
  end

  xdescribe '#format_text_for_alexa' do

  end
end
