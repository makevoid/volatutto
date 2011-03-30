require 'redis'
require 'mechanize'

path = File.expand_path "../", __FILE__
require "#{path}/volagratis.rb"

start = "MIL"
dest  = "TYO"
date = Date.new 2011, 6, 14
return_date = Date.new 2011, 7, 17
days = 1

vg = Volagratis.new(start, dest, date, return_date, days)
#vg.redis.wipe
vg.search
p vg.results

keys = vg.redis.keys('*')
p keys

keys.each do |key|
  p vg.redis.lrange(key, 0, -1)
end