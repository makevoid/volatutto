require 'redis'

class Redis
  def wipe
    self.keys("*").each{ |k| self.del k }
  end
end

r = Redis.new
r.wipe
#r.flushdb
keys = r.keys("*")

keys.each do |key|
  puts "#{key} > #{r[key]}"
end


