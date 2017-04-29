class AlexaInterfaceController < ApplicationController
  def recommend
    respond_to do |f|
      f.json {render json: {stuff: "things"}}
    end
  end
end
