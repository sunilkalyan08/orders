require 'pry'
require 'redis'
def generate_order_number(user_id=5570)
  $redis = Redis.new(url: "redis://localhost:6379")
  if $redis.ping()
    current_timestamp = $redis.time
    ordid = "od#"+current_timestamp[0].to_s + current_timestamp[1].to_s
    $redis.sadd("user_orders_#{user_id}", ordid)
    # p "The Order id is - #{ordid}"
    ordid
  end
rescue => e
  p "Redis is not started"
end


def fetch_order_numbers(user_id=5570)
  $redis = Redis.new(url: "redis://localhost:6379")
  orders = $redis.smembers("user_orders_#{user_id}")
  # p "Here is the list of orders - #{orders}"
  orders
end


p generate_order_number
p fetch_order_numbers
