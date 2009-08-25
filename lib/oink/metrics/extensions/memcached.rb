module Oink
  module Metrics
    module Extensions
      module Memcached
        def self.add_to(log)
          if defined?(Memcached)
            log.add Timer.new(:memcache)
            log.add Counter.new(:memcache_writes)
            log.add Counter.new(:memcache_hits)
            log.add Counter.new(:memcache_misses)
          end
        end
      end
    end
  end
end

if defined?(Memcached)
  Memcached.class_eval do
    extend Oink::MethodTracker

    add_method_incr :memcache_writes, :set
    add_method_incr :memcache_writes, :add
    add_method_incr :memcache_writes, :increment
    add_method_incr :memcache_writes, :decrement
    add_method_incr :memcache_writes, :replace
    add_method_incr :memcache_writes, :append
    add_method_incr :memcache_writes, :prepend
    add_method_incr :memcache_writes, :delete

    add_method_timer :memcache, :set
    add_method_timer :memcache, :add
    add_method_timer :memcache, :increment
    add_method_timer :memcache, :decrement
    add_method_timer :memcache, :replace
    add_method_timer :memcache, :append
    add_method_timer :memcache, :prepend
    add_method_timer :memcache, :delete

    def get_with_stats_log(keys, marshal=true)
      if keys.is_a? Array
        results = Oink.measure(:memcache) do
          get_without_stats_log(keys, marshal)
        end

        keys.each do |key|
          if results.has_key?(key)
            Oink.incr(:memcache_hits)
          else
            Oink.incr(:memcache_misses)
          end
        end

        return results
      else
        begin
          result = Oink.measure(:memcache) do
            get_without_stats_log(keys, marshal)
          end
          Oink.incr(:memcache_hits)
          return result
        rescue Memcached::NotFound => ex
          Oink.incr(:memcache_misses)
          raise
        end
      end
    end

    alias_method_chain :get, :stats_log
  end
end