require 'redis'
require 'mechanize'
require 'digest/md5'

# `curl "http://airportcode.riobard.com/search?q=frankfurt&fmt=JSON"` # useful

AIRPORTS = ["MIL", "TYO"]


class Redis
  def wipe
    self.keys("*").each{ |k| self.del k }
  end
end


class Volagratis
  attr_reader :results
  attr_reader :redis
  
  TIME_FORMAT = "%Y%m%d"
  MONTHYEAR = "%m%Y"
  
  QUERY_URL = "http://www.volagratis.com/vg1/search3.do?%s"
  URL = "http://www.volagratis.com/capitanprice/Search?%s"
  
  REDIS = Redis.new
  
  def initialize(start, dest, date, return_date, days=1)
    @start = start
    @dest = dest
    @date = date
    @return_date = return_date
    @days = days
    @results = []
    # async
    @redis = REDIS
    @threads = []
    @key = "#{@start}:#{@dest}:#{@date}:#{@return_date}"
    #Digest::MD5.hexdigest Time.now.to_i.to_s
  end
  
  def results
    @threads.each{ |t| t.join }
    @results
  end
  
  def async(&block)
    @threads << Thread.new {
      result = block.call
      self.redis.rpush @key, result
    }
    sleep 0.2
  end
  
  def http_search(date, return_date)
    agent = Mechanize.new
    agent.read_timeout = 6
    agent.user_agent = "Mac Safari"
    
    query_params = "&departureAirport=#{@start}&arrivalAirport=#{@dest}&outboundDay=#{date.day}&outboundMonthYear=#{date.strftime MONTHYEAR}&roundtrip=true&adults=1&childs=0&infants=0&currency=EUR&xrate=1&locale=en_US&returnDay=#{return_date.day}&returnMonthYear=#{return_date.strftime MONTHYEAR}"
    query_url = QUERY_URL % query_params
    query_page = agent.post query_url
    # p query_page
    # puts "QUERY"
    
    params = "departureAirport=#{@start}&arrivalAirport=#{@dest}&outboundDate=#{date.strftime TIME_FORMAT}&adults=1&childs=0&infants=0&currency=EUR&xrate=1&locale=en_US&returnDate=#{return_date.strftime TIME_FORMAT}"
    url = URL % params
    page = agent.get url
    # p page
    # puts "PAGE"
    
    page.body.scan(/^\d+/).first
  end
  
  def search
    dates = calc_dates @date
    return_dates = calc_dates @return_date
    
    dates.each do |date|
      return_dates.each do |return_date|
        async do
          begin
            http_search(date, return_date)
          rescue  Net::HTTPServiceUnavailable
            puts "503 on #{date} - #{return_date}"
          rescue Timeout::Error
            puts "Timeout on #{date} - #{return_date}"
          rescue Net::HTTPGatewayTimeOut 
            puts "Timeout on #{date} - #{return_date}"
          end
        end
      end
    end
  end
  
  
  private
  
  def calc_dates(date)
    (date-@days..date+@days).to_a
  end
end





  