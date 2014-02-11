require 'redis'
require 'singleton'
require 'json'

module OverlayPublisher
  class Redis
    include Singleton

    def publish_hook(body)
      begin
        payload     = JSON.parse(body)
        repository  = payload['repository']['name']
        user        = payload['repository']['organization']
        key         = "overlay_publisher_#{user}_#{repository}"
        redis.publish key, body
      rescue Exception => e
        raise "Unexpected payload found.  Message: #{e.message}"
      end
    end

    private

    def redis
      @redis ||= ::Redis.new(host: App.settings.redis['service_host'], port: App.settings.redis['port'])
    end
  end
end