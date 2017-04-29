Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  post '/alexa_interface', to: 'alexa_interface#recommend'
end
