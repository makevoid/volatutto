
#require 'digest/md5'

# `curl "http://airportcode.riobard.com/search?q=frankfurt&fmt=JSON"` # useful

AIRPORTS = ["MIL", "TYO"]


class Redis
  def wipe
    self.keys("*").each{ |k| self.del k }
  end
end


class Volagratis
  attr_reader :redis
  
  TIME_FORMAT = "%Y%m%d"
  DEFAULT_FORMAT = "%d/%m/%Y"
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
    # async
    @redis = REDIS
    @threads = []
    #Digest::MD5.hexdigest Time.now.to_i.to_s
    Thread.abort_on_exception = true
  end
  
  def join_threads
    @threads.each{ |t| t.join }
  end
  
  def async(&block)
    @threads << Thread.new {
      result, start, dest, date, return_date = block.call
      key = "#{start}:#{dest}:#{date}:#{return_date}"
      self.redis.set key, result
    }
    sleep 0.05
  end
  
  def http_search(start, dest, date, return_date)
    require 'mechanize'
    agent = Mechanize.new
    agent.read_timeout = 6
    agent.user_agent = "Mac Safari"
    
    query_params = "&departureAirport=#{start}&arrivalAirport=#{dest}&outboundDay=#{date.day}&outboundMonthYear=#{date.strftime MONTHYEAR}&roundtrip=true&adults=1&childs=0&infants=0&currency=EUR&xrate=1&locale=en_US&returnDay=#{return_date.day}&returnMonthYear=#{return_date.strftime MONTHYEAR}"
    query_url = QUERY_URL % query_params
    query_page = agent.post query_url
    # p query_page
    # puts "QUERY"
    
    params = "departureAirport=#{start}&arrivalAirport=#{dest}&outboundDate=#{date.strftime TIME_FORMAT}&adults=1&childs=0&infants=0&currency=EUR&xrate=1&locale=en_US&returnDate=#{return_date.strftime TIME_FORMAT}"
    url = URL % params
    page = agent.get url
    # p page
    # puts "PAGE"
    
    price = page.body.scan(/^\d+/).first
    [price, start, dest, date, return_date]
  end
  
  def search
    dates = calc_dates @date
    return_dates = calc_dates @return_date
    
    dates.each do |date|
      return_dates.each do |return_date|
        key = "#{@start}:#{@dest}:#{date}:#{return_date}"
        get_price(@start, @dest, date, return_date) unless @redis.exists key
      end
    end
  end
  
  def calc_dates(date)
    (date-@days..date+@days).to_a
  end
  
  private
  
  def get_price(start, dest, date, return_date)
    async do
      begin
        http_search(start, dest, date, return_date)
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





  