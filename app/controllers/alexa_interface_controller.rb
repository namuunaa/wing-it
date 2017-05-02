class AlexaInterfaceController < ApplicationController
  def recommend
    respond_to do |f|

      f.json do
        if params["request"]["intent"]
          case params["request"]["intent"]["name"]

          when "WingItIntent"
            render json: create_response(get_location)
          when "SetCityIntent"
            city = get_city_from_json
            user_id = get_user_id
            @user = User.find_or_initialize_by(user_id: user_id)
            @user.city = city
            @user.save
            render json: build_city_set_response(@user)
          end
        else
          render json: create_response(get_location)
        end
      end
    end
  end
end
