require "bunny"

conn = Bunny.new(:automatically_recover => false)
conn.start

ch   = conn.create_channel
# durable: 서버가 꺼져도 잃어버리지 않게
q    = ch.queue("task_queue", :durable => true)

# prefetch 한 worker에서 한번에 많은 양의 queue를 주지말아라!
# n = 1;
# ch.prefetch(n);

begin
  puts " [*] Waiting for messages. To exit press CTRL+C"
#manual_ack:  queue를 처리하던 consumer가 꺼지면 다른 consumer에게 queue를 넘김
  q.subscribe(:manual_ack => true, :block => true) do |delivery_info, properties, body|
    puts " [x] Received #{body}"
    # imitate some work
    sleep body.count(".").to_i
    puts " [x] Done"
  end
rescue Interrupt => _
  conn.close

  exit(0)
end
