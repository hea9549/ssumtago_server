require "bunny"

conn = Bunny.new(:automatically_recover => false)
conn.start

ch   = conn.create_channel
# exchange
x = ch.fanout("logs")

# durable: 서버가 꺼져도 잃어버리지 않게
# q    = ch.queue("task_queue", :durable => true)
# 이름이 비어있으면 non-durable queue with a generated name를 만든다.
# q = ch.queue("", :exclusive => true)
msg  = ARGV.empty? ? "Hello World!" : ARGV.join(" ")


# exchange
x.publish(msg)

# bingding (exchange가 queue에게 메세지를 보내는 것)
# q.bind("logs")


#  persistent 서버가 꺼져도 그대로!
q.publish(msg, :persistent => true)

# ch.default_exchange.publish("Hello World!", :routing_key => q.name)
puts " [x] Sent 'Hello World!'"

conn.close
