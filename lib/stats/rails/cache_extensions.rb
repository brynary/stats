if defined?(Memcached)
  Memcached.class_eval do

    def set_with_stats_log(key, value, timeout=0, marshal=true)
      Stats.broadcaster.incr(:memcache_writes)
      Stats.broadcaster.measure(:memcache) do
        set_without_stats_log(key, value, timeout, marshal)
      end
    end

    def add_with_stats_log(key, value, timeout=0, marshal=true)
      Stats.broadcaster.incr(:memcache_writes)
      Stats.broadcaster.measure(:memcache) do
        add_without_stats_log(key, value, timeout, marshal)
      end
    end

    def increment_with_stats_log(key, offset=1)
      Stats.broadcaster.incr(:memcache_writes)
      Stats.broadcaster.measure(:memcache) do
        increment_without_stats_log(key, offset)
      end
    end

    def decrement_with_stats_log(key, offset=1)
      Stats.broadcaster.incr(:memcache_writes)
      Stats.broadcaster.measure(:memcache) do
        decrement_without_stats_log(key, offset)
      end
    end

    def replace_with_stats_log(key, value, timeout=0, marshal=true)
      Stats.broadcaster.incr(:memcache_writes)
      Stats.broadcaster.measure(:memcache) do
        replace_without_stats_log(key, value, timeout, marshal)
      end
    end

    def append_with_stats_log(key, value)
      Stats.broadcaster.incr(:memcache_writes)
      Stats.broadcaster.measure(:memcache) do
        append_without_stats_log(key, value)
      end
    end

    def prepend_with_stats_log(key, value)
      Stats.broadcaster.incr(:memcache_writes)
      Stats.broadcaster.measure(:memcache) do
        prepend_without_stats_log(key, value)
      end
    end

    def delete_with_stats_log(key)
      Stats.broadcaster.incr(:memcache_writes)
      Stats.broadcaster.measure(:memcache) do
        delete_without_stats_log(key)
      end
    end

    def get_with_stats_log(keys, marshal=true)
      if keys.is_a? Array
        results = Stats.broadcaster.measure(:memcache) do
          get_without_stats_log(keys, marshal)
        end
        
        keys.each do |key|
          if results.has_key?(key)
            Stats.broadcaster.incr(:memcache_hits)
          else
            Stats.broadcaster.incr(:memcache_misses)
          end
        end
        
        return results
      else
        begin
          result = Stats.broadcaster.measure(:memcache) do
            get_without_stats_log(keys, marshal)
          end
          Stats.broadcaster.incr(:memcache_hits)
          return result
        rescue Memcached::NotFound => ex
          Stats.broadcaster.incr(:memcache_misses)
          raise
        end
      end
    end

    alias_method_chain :decrement,  :stats_log
    alias_method_chain :get,        :stats_log
    alias_method_chain :increment,  :stats_log
    alias_method_chain :set,        :stats_log
    alias_method_chain :add,        :stats_log
    alias_method_chain :replace,    :stats_log
    alias_method_chain :delete,     :stats_log
    alias_method_chain :prepend,    :stats_log
    alias_method_chain :append,     :stats_log
  end
end