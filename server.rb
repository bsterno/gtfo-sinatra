require 'sinatra'
require 'sinatra/json'
require 'httparty'
require 'pry'

use Rack::Session::Cookie, {
  # secret: "is_it_secret_is_it_safe"
}

get "/" do
  redirect "/gtfo"
end

get '/gtfo' do
  location = HTTParty.get('http://api.divesites.com')
  city = location["loc"]["city"]
  region = location["loc"]["region_name"]
  response = HTTParty.get("https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{location["loc"]["lat"]},#{location["loc"]["lng"]}&radius=10000&types=park&campground=cruise&key=AIzaSyBRo-mtutP62p-Z5mPGwgZj0fArDw7e_7A")
  places = response["results"]

  places.each do |data|
    session["#{data["name"]}"] = data["place_id"]
  end

  erb :index, locals: { places: places, city: city, region: region }
end

get '/gtfo/:park_name' do
  place_id = session[params[:park_name]]
  location = HTTParty.get('http://api.divesites.com')
  city = location["loc"]["city"]
  region = location["loc"]["region_name"]
  park = params[:park_name]
  place_info = HTTParty.get("https://maps.googleapis.com/maps/api/place/details/json?placeid=#{place_id}&key=AIzaSyBRo-mtutP62p-Z5mPGwgZj0fArDw7e_7A")
  place_reviews = place_info["result"]["reviews"]
  erb :show, locals: { park: park, city: city, region: region, place_reviews: place_reviews, place_info: place_info }
end
