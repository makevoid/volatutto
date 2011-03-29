set :haml, { :format => :html5 }


# require 'dm-core'
# require 'dm-sqlite-adapter'
# 
# DataMapper.setup :default, "sqlite://#{APP_PATH}/db/app.sqlite"
# 
# 
# Dir.glob("#{APP_PATH}/models/*").each do |model|
#   require model
# end

require 'voidtools'
include Voidtools::Sinatra::ViewHelpers

module Blanker
  def blank?
    self.nil? || self == ""
  end
end

class String
  include Blanker
end

class NilClass
  include Blanker
end