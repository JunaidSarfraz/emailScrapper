Rails.application.routes.draw do
  root "home#index"
  resources :home, only:[] do
  	collection do
  		post	:extract_urls_count
  		post	:get_records
  	end
  end
end
