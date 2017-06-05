#!/usr/bin/env ruby
# encoding: utf-8

require "bunny"
require 'json'

# conn = Bunny.new("amqp://ssumtago:Tjaxkrh@127.0.0.1")
conn = Bunny.new(:host => "localhost", :vhost => "pushHost", :user => "ssumtago", :password => "Tjaxkrh")
conn.start

ch   = conn.create_channel
q    = ch.queue("ssumPredict")
requestSurvey  = {hello:"GO!"}
ch.default_exchange.publish( requestSurvey.to_json, :routing_key => q.name )


puts " [x] Sent #{requestSurvey.to_json}"

conn.close

# begin
#   conn = Bunny.new("amqp://guest8we78w7e8:guest2378278@127.0.0.1")
#   conn.start
# rescue Bunny::PossibleAuthenticationFailureError => e
#   puts "Could not authenticate as #{conn.username}"
# end
