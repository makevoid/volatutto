require 'haml'
require 'sass'
require 'json'
require 'sinatra'
enable :sessions

path = File.expand_path "../", __FILE__
APP_PATH = path

class Volavola < Sinatra::Base
  require "#{APP_PATH}/config/env"
  
  set :haml, { :format => :html5 }
  require 'rack-flash'
  enable :sessions
  use Rack::Flash
  require 'sinatra/content_for'
  helpers Sinatra::ContentFor
  set :method_override, true

  require  "#{APP_PATH}/lib/form_helpers"
  helpers FormHelpers

  def not_found(object=nil)
    halt 404, "404 - Page Not Found"
  end
  
  def self.match(url, &block)
    get url, &block
    post url, &block
  end
  
  match "/search.json" do
    content_type :json
    results = []
    results << {
      start_date: "15/6/2011",
      end_date: "15/7/2011",
      price: "123",
      link: "#"
    }
    results << {
      start_date: "16/6/2011",
      end_date: "15/7/2011",
      price: "124",
      link: "#"
    }
    { results: results }.to_json
  end

  get "/" do
    haml :index
  end

  get '/css/main.css' do
    sass :main
  end
  
end