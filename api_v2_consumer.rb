require 'hutch'
require 'march_hare' if RUBY_PLATFORM == 'java'

class ApiV2Consumer
  include Hutch::Consumer

  def process(message)
    Hutch.publish(message.properties.reply_to, { result: fibonacci(message.body[:n]) }, correlation_id: message.properties.correlation_id)
  end

  private

  def fibonacci(value)
    return value if value.zero? || value == 1

    fibonacci(value - 1) + fibonacci(value - 2)
  end
end

