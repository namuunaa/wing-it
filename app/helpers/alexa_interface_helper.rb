module AlexaInterfaceHelper

  # uses everything and returns a full response object to send to alexa
  def create_response(call_parameters)
    response_for_alexa = AlexaRubykit::Response.new
    response = call(call_parameters)
    top_ten = pick10(response)
    top_one = pick1(top_ten)
    format_speech_for_alexa(response_for_alexa, top_one)
    format_text_for_alexa(response_for_alexa, top_ten)
    response_for_alexa.build_response
  end

  # Make an api call to eventful and return an array of events (probably super huge long awful list)
  def call(call_parameters)

  end

  # Run call, then select ten of the call items. Returns array with length 10 or less
  def pick10(call_list)
    #
  end

  # Run pick ten (or run on output of pick ten, might be more DRY), picks top result. returns top result
  def pick1(ten_events)

  end

  # use the alexa gem to add speech to response for alexa. doesn't need return as it's just side effects we want
  def format_speech_for_alexa(response_for_alexa, single_event)

  end

  # use the alexa gem to add text cards to give to alexa's companion app. doesn't need return as it's just side effects we want
  def format_text_for_alexa(response_for_alexa, top_ten_events)

  end

end
