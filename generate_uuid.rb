require 'redis'
require 'securerandom'
require 'pry'
$counter = 0
def generate_order_number(user_id=5570)
  $redis = Redis.new(url: "redis://localhost:6379")
  if $redis.ping()
    current_timestamp = $redis.time
    ordid = "od#"+current_timestamp[0].to_s + current_timestamp[1].to_s
    # Check the order id is present, if present re-generate it with counter check
    if check_unique_order("redis", user_id, ordid)
      if $counter < 1
        $counter+=1
        generate_order_number(user_id)
      else
        p "Please try after 30 seconds"
      end
    else
      $redis.sadd("user_orders_#{user_id}", ordid)
    end
    # p "The Order id is - #{ordid}"
  end
rescue => e
  p "Redis is not started so generating key through ruby and storing in DB"
  ordid = "od#"+SecureRandom.uuid.to_s + Time.now.to_i.to_s
  if check_unique_order("db", user_id, ordid)
    if $counter < 1
      $counter+=1
      generate_order_number(user_id)
    else
      p "Please try after 30 seconds"
    end
  else
    Order.create(ordid: ordid)
  end
end

def check_unique_order(type,user_id, ordid)
  bool = true
  if type == "redis"
    orders = fetch_order_numbers(user_id)
  else
    # Assuming the orders are storing in Order Table. Duplicate check with DB for uniq ordId
    # create a index on the order id for searching faster
    orders = Order.where(ordid: ordid)
  end
  bool = orders.include?(ordid) ? true : false
  bool
end


def fetch_order_numbers(user_id=5570)
  $redis = Redis.new(url: "redis://localhost:6379")
  orders = $redis.smembers("user_orders_#{user_id}")
  # p "Here is the list of orders - #{orders}"
  orders
end


p generate_order_number
p fetch_order_numbers
