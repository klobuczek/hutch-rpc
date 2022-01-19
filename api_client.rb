#!/usr/bin/env ruby
require 'bunny'
require 'thread'
require 'json'

class FibonacciClient
  attr_reader :call_id, :lock, :condition
  attr_writer :response

  def initialize
    @connection = Bunny.new(automatically_recover: false)
    @connection.start

    @channel = @connection.create_channel

    setup_reply_queue
  end

  def call(n)
    @call_id = generate_uuid

    @channel.default_exchange.publish(
      JSON.generate(n: n),
      routing_key: 'api_v2_consumer',
      correlation_id: @call_id,
      reply_to: 'amq.rabbitmq.reply-to')

    # wait for the signal to continue the execution
    @lock.synchronize { condition.wait(lock) }

    @response
  end

  def stop
    @channel.close
    @connection.close
  end

  private

  def setup_reply_queue
    @lock = Mutex.new
    @condition = ConditionVariable.new
    that = self

    @channel.queue('amq.rabbitmq.reply-to').subscribe do |_delivery_info, properties, payload|
      if properties[:correlation_id] == that.call_id
        that.response = payload

        # sends the signal to continue the execution of #call
        that.lock.synchronize { that.condition.signal }
      end
    end
  end

  def generate_uuid
    # very naive but good enough for code examples
    "#{rand}#{rand}#{rand}"
  end
end

client = FibonacciClient.new

puts ' [x] Requesting fib(30)'
response = client.call(30)

puts " [.] Got #{response}"

client.stop