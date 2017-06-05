#!/usr/bin/env ruby
# encoding: utf-8

require "bunny"
require 'json'

conn = Bunny.new("amqp://ssumtago:Tjaxkrh@127.0.0.1")
conn.start

ch   = conn.create_channel
q    = ch.queue("ssumPredict")
requestSurvey  = {hello:"GO!"}
ch.default_exchange.publish( requestSurvey.to_json, :routing_key => q.name )


puts " [x] Sent #{requestSurvey.to_json}"

conn.close
