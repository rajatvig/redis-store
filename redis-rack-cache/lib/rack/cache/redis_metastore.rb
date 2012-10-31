require 'digest/sha1'
require 'rack/utils'
require 'rack/cache/key'
require 'rack/cache/metastore'

module Rack
  module Cache
    class MetaStore
      class RedisBase < self
        extend Rack::Utils

        # The Redis::Store object used to communicate with the Redis daemon.
        attr_reader :cache

        def self.resolve(uri)
          new ::Redis::Factory.resolve(uri.to_s)
        end
      end

      class Redis < RedisBase
        # The Redis instance used to communicated with the Redis daemon.
        attr_reader :cache

        def initialize(server, options = {})
          @cache = ::Redis::Factory.create(server)
        end

        def read(key)
          cache.get(hexdigest(key)) || []
        end

        def write(key, entries, ttl=nil)
          if ttl.to_i.zero?
            cache.set(hexdigest(key), entries)
          else
            cache.set(hexdigest(key), entries)
            cache.expire(hexdigest(key), ttl)
          end
        end

        def purge(key)
          cache.del(hexdigest(key))
          nil
        end
      end

      REDIS = Redis
    end
  end
end
