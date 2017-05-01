module AlexaInterfaceHelper

  # uses everything and returns a full response object to send to alexa
  def create_response(call_parameters)
    response_for_alexa = AlexaRubykit::Response.new
    response = call(call_parameters)
    not_started = select_not_started(response)
    top_ten = pick10(not_started)
    top_one = pick1(top_ten)
    format_speech_for_alexa(response_for_alexa, top_one)
    format_text_for_alexa(response_for_alexa, top_ten)
    response_for_alexa.build_response
  end

  # Make an api call to eventful and return an array of events (probably super huge long awful list)
  def call(call_parameters={})
    parameters_hash = { location: "New York", date: "Today", sort_order: "popularity", mature: "normal", page_size: 30, change_multi_day_start: "true" }
    if call_parameters['postalCode']
      parameters_hash[:location] = call_parameters['postalCode']
    end
    client = EventfulApi::Client.new({})
    response = client.get('/events/search', parameters_hash)
    # hash > "events" > "event" > array of events
    response["events"]["event"]
  end

  #limit the selection to events that have not yet started or are all-day events
  def select_not_started(call_list)
    call_list.select do |event|
      Time.parse(event["start_time"]).future? || event["all_day"] != "0"
    end
  end

  # Run call, then select ten of the call items. Returns array with length 10 or less
  def pick10(events_list)
    events_list[0..9]
  end

  # Run pick ten (or run on output of pick ten, might be more DRY), picks top result. returns top result
  def pick1(ten_events)
    ten_events.first
  end

  # Takes the start time of the event and substracts from Time.now, to show hours until format
  def time_until(event_start_date)
    current_time = DateTime.now
    current_total_minute = current_time.hour * 60 + current_time.minute
    event_total_minute = event_start_date.hour * 60 + event_start_date.minute
    time_until = event_total_minute - current_total_minute
    hour_until = time_until / 60
    minute_until = time_until % 60
    "#{hour_until} hours and #{minute_until} minutes"
  end

  # use the alexa gem to add speech to response for alexa. doesn't need return as it's just side effects we want
  def format_speech_for_alexa(response_for_alexa, single_event)
    event_name = single_event['title']
    venue_name = single_event['venue_name']
    start_date = single_event['start_time']
    start_time = DateTime.parse(start_date).strftime('%l:%M %p')
    time_until = time_until(DateTime.parse(start_date))
    response_for_alexa.add_speech("#{event_name} is happening at #{venue_name} starting at #{start_time}. You have #{time_until} to get ready.")
  end

  # use the alexa gem to add text cards to give to alexa's companion app. doesn't need return as it's just side effects we want
  def format_text_for_alexa(response_for_alexa, top_ten_events)
    content_for_alexa = top_ten_events.reduce("") do |total_string, event|
      total_string + "\n \n" + generate_single_event_text_for_card(event)
    end
    # We'd like to use Standard cards so we can eventually include images but the alexa wants text as an argument instead of content for a standard card and the gem doesn't do that. Thus we have to use a simple card
    response_for_alexa.add_card('Simple', 'Top events for tonight!', nil, content_for_alexa)
  end

  def generate_single_event_text_for_card(event)
    event_name = event['title']
    venue_name = event['venue_name']
    start_date = event['start_time']
    url = event['url']
    description = find_formatted_description(event)
    start_time = DateTime.parse(start_date).strftime('%l:%M %p')
    "Event: #{event_name} \n Venue: #{venue_name} \n Time: #{start_time} \n Description: #{description} \n More Info: #{url}"
  end

  # take care of edge case where there's no description within the event hash
  def find_formatted_description(event)
    if event['description']
      format_html_text_to_string(event['description'])
    else
      'We don\'t have any details on this event'
    end
  end

  # remove br tags and &quot; formating and parse it into alexa writable strings
  # can refactor with sanitize for nokogiri
  def format_html_text_to_string(html_text)
    escaped_br_text = html_text.gsub("<br>", "-=-=-0-=")
    text_with_quotes = Nokogiri::HTML(escaped_br_text).text
    formatted_text = text_with_quotes.gsub("-=-=-0-=", "\n")
    if formatted_text.length > 500
      formatted_text[(0...500)] + "..."
    else
      formatted_text
    end
  end

  # uses information from alexa's json object in request to get the zip code of the device
  def get_location
    return {} unless params['context']
    device_id = get_device_id
    consent_token = get_consent_token
    return {} unless consent_token
    make_alexa_location_api_call(device_id, consent_token)
  end

  # accesses params sent by alexa to get the device id needed in the api call
  def get_device_id
    # this nesting is pulled from the alexa website
    params['context']['System']['device']['device_id']
  end

  # accesses params sent by alexa to get the consent token needed in the api call
  def get_consent_token
    # this nesting is pulled from the alexa website
    params['context']['System']['user']['permissions']['consentToken']
  end

  # use the above two pieces of information to make an amazon address api call to get the country and postal code of the user
  def make_alexa_location_api_call(device_id, consent_token)
    HTTParty.get("https://api.amazonalexa.com/v1/devices/#{device_id}/settings/address/countryAndPostalCode
", headers: {"Authorization" => "Bearer Atc|#{consent_token}"})
  end

end
