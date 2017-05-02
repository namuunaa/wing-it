require 'rails_helper'

RSpec.describe AlexaInterfaceController, :type => :controller do
  describe '#recommend' do
    it 'accepts returns a json object to a json post request' do
      json = { 'format' => 'json',
               'request' => { 'intent' => { 'name' => 'SetCityIntent', 'slots' => { 'city' => { 'value' => "City" } } } },
               "session" => { 'user' => { 'userId' => "userId"} } }
      post :recommend, json
    end

    it 'will set a user location when intent is SetCityIntent' do
      json = { 'format' => 'json',
               'request' => { 'intent' => { 'name' => 'SetCityIntent', 'slots' => { 'city' => { 'value' => "City" } } } },
               "session" => { 'user' => { 'userId' => "userId"} } }
      post :recommend, json
      expect(assigns(:user)).to be_kind_of(User)
      expect(assigns(:user).user_id).to eq("userId")
      expect(assigns(:user).city).to eq("City")
    end
    # spy on, runs create response
    it 'will run default without an intent' do
      json = { 'format' => 'json',
               'request' => { 'intent' => "intent" },
               "session" => { 'user' => { 'userId' => "userId"} } }
      post :recommend, json
      p response
    end

  end
end
