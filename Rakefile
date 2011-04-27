path = File.expand_path "../", __FILE__
# load_tasks 'lib/tasks/*'

namespace :db do
  desc "clear"
  task :clear do
    require 'redis'
    r = Redis.new
    keys = r.keys
    keys.each{ |k| r.del k }
    puts "Deleted #{keys.size} keys"
  end  
end
