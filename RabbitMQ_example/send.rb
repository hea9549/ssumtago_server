require "bunny"

conn = Bunny.new(:automatically_recover => false)
conn.start

ch   = conn.create_channel
q    = ch.queue("ssumPredict")

ch.default_exchange.publish("Hello World!", :routing_key => q.name)
puts " [x] Sent 'Hello World!'"

conn.close


# channel.queue_declare(queue='ssumPredict')
# channel.basic_publish(exchange='',
#                       routing_key='ssumPredict',
#                       body=json.dumps(requestSurvey))
