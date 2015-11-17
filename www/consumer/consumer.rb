#!/usr/bin/env ruby

require 'bunny'
require 'serverengine'

module RabbitmqConsumer
  def run
    conn = Bunny.new(hearbeat: 10, logger: logger).tap(&:start)
    ch = conn.create_channel
    q = ch.queue('publisher.readings', auto_delete: false, durable: true)
    q.subscribe(block: true, manual_ack: true) do |delivery_info, _md, payload|
      logger.debug "received data: [#{payload}]"
      ch.ack(delivery_info.delivery_tag)
    end
  end
end

ServerEngine.create(nil, RabbitmqConsumer,
  supervisor: true,
  log_level: :debug,
  worker_type: 'process',
  workers: 2
).run
