require 'bunny_pusher'

class App
  def call(env)
    if 'POST' == env['REQUEST_METHOD']
      BunnyPusher.publish("reading #{number}", routing_key: 'publisher.readings')
      ['201', {}, []]
    else
      ['405', {}, []]
    end
  end

  def number
    @@number ||= 0
    @@number += 1
  end
end
