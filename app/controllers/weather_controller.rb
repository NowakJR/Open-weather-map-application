class WeatherController < ApplicationController
  def index
    if params[:q]
      @weather = Request.get_json(params[:q])
    else
      @weather = "Enter a city name to get its current weather details!"
    end

    respond_to do |format|
      format.js
      format.html
    end
  end
end
require 'faraday'
require 'json'

class Connection
  BASE = 'https://api.openweathermap.org/data/2.5/weather'

  def self.api(query)
    Faraday.new(url: BASE) do |faraday|
      faraday.response :logger
      faraday.adapter Faraday.default_adapter
      faraday.params['units'] = 'metric'
      faraday.params['q'] = query
      faraday.params['appid'] = ENV['WEATHER_API_KEY']
      faraday.headers['Content-Type'] = 'application/json'
    end
  end
end
class Request
  class << self


    def get(id)
      response, status = get_json(id)
      status == 200 ? response : errors(response)
    end

    def errors(response)
      error = { errors: { status: response["status"], message: response["message"] } }
      response.merge(error)
    end

    def get_json(query)
      response = api(query).get
      [JSON.parse(response.body), response.status]
    end

    def api(query)
      Connection.api(query)
    end
  end
end