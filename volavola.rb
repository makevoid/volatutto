require 'haml'
require 'sass'
require 'json'
require 'sinatra'
require 'date'
require 'redis'
require 'net/http'
enable :sessions


path = File.expand_path "../", __FILE__
APP_PATH = path

require "#{path}/models/volagratis"

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
  
  MONTHYEAR = "%m%Y"
  def build_url(start, dest, date, return_date)
    "http://www.volagratis.com/vg1/searching.do?url=search3.do&departureAirport=#{start}&arrivalAirport=#{dest}&outboundDay=#{date.day}&outboundMonthYear=#{date.strftime MONTHYEAR}&roundtrip=true&adults=1&childs=0&infants=0&currency=EUR&xrate=1&locale=it_IT&returnDay=#{return_date.day}&returnMonthYear=#{return_date.strftime MONTHYEAR}"
  end
  
  match "/search.json" do
    content_type :json
    results = []
    
    start = params[:from].upcase
    dest = params[:to].upcase
    date = Date.parse params[:date]
    return_date = Date.parse params[:return_date]
    days = 1
    days = params[:days].to_i unless params[:days].blank?
    
    raise not_found if start.blank? || dest.blank? || date.nil? || return_date.nil?
    
    vg = Volagratis.new(start, dest, date, return_date, days)
    #vg.redis.wipe
    vg.search
    vg.join_threads
    
    dates = vg.calc_dates date
    return_dates = vg.calc_dates return_date
    
    dates.each do |date|
      return_dates.each do |return_date|
        key = "#{start}:#{dest}:#{date}:#{return_date}"
        price = vg.redis.get key
        url = build_url(start, dest, date, return_date)
        results << {
          start_date: date,
          end_date: return_date,
          price: price,
          link: url,
        }
      end
    end
    
    { results: results }.to_json
  end

  get "/" do
    haml :index
  end

  get '/css/main.css' do
    sass :main
  end
  
end