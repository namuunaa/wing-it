require 'rails_helper'

RSpec.describe AlexaInterfaceController, :type => :controller do
  describe '#recommend is really the only controller method' do
    it 'accepts returns a json object to a json post request' do
      json = { :format => 'json', :application => { :name => "foo", :description => "bar" } }
      post :recommend, json
      expect(response.header['Content-Type']).to include 'application/json'
    end
  end
end
