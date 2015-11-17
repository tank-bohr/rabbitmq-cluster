require 'bunny'

class BunnyPusher
  OPTIONS = {
    connection_timeout: 1,
    heartbeat: 10
  }.freeze

  class ConnectionError < ::StandardError
    def initialize
      super 'RabbitMQ is not connected'
    end
  end

  def self.publish(data, options = {})
    new.publish(data, options)
  end

  def initialize
    establish_connection if connection.nil?
  rescue Bunny::TCPConnectionFailed
    puts "Couldn't conntect to rabbitmq"
  end

  def publish(data, options)
    fail ConnectionError unless connected?
    init_queues
    options[:persistent] = true
    exchange.publish(data, options)
  rescue Bunny::ChannelAlreadyClosed
    @@channel = connection.create_channel
    raise
  end

  def connection
    if defined? @@connection
      @@connection
    else
      @@connection = nil
    end
  end

  def channel
    if defined? @@channel
      @@channel
    else
      @@channel = nil
    end
  end

  private

  def establish_connection
    @@connection = Bunny.new(OPTIONS).tap(&:start)
      .tap { |c| @@channel = c.create_channel }
  end

  def connected?
    connection && connection.connected?
  end

  def init_queues
    ['publisher.readings', 'activity.stories'].each do |route|
      channel.queue(route.freeze, durable: true)
    end
  end

  def exchange
    @exchange ||= channel.default_exchange
  end
end
