if defined?(Memcached)
  Memcached.class_eval do

    def set_with_stats_log(key, value, timeout=0, marshal=true)
      $stats.incr(:memcache_writes)
      $stats.measure(:memcache) do
        set_without_stats_log(key, value, timeout, marshal)
      end
    end

    def add_with_stats_log(key, value, timeout=0, marshal=true)
      $stats.incr(:memcache_writes)
      $stats.measure(:memcache) do
        add_without_stats_log(key, value, timeout, marshal)
      end
    end

    def increment_with_stats_log(key, offset=1)
      $stats.incr(:memcache_writes)
      $stats.measure(:memcache) do
        increment_without_stats_log(key, offset)
      end
    end

    def decrement_with_stats_log(key, offset=1)
      $stats.incr(:memcache_writes)
      $stats.measure(:memcache) do
        decrement_without_stats_log(key, offset)
      end
    end

    def replace_with_stats_log(key, value, timeout=0, marshal=true)
      $stats.incr(:memcache_writes)
      $stats.measure(:memcache) do
        replace_without_stats_log(key, value, timeout, marshal)
      end
    end

    def append_with_stats_log(key, value)
      $stats.incr(:memcache_writes)
      $stats.measure(:memcache) do
        append_without_stats_log(key, value)
      end
    end

    def prepend_with_stats_log(key, value)
      $stats.incr(:memcache_writes)
      $stats.measure(:memcache) do
        prepend_without_stats_log(key, value)
      end
    end

    def delete_with_stats_log(key)
      $stats.incr(:memcache_writes)
      $stats.measure(:memcache) do
        delete_without_stats_log(key)
      end
    end

    def get_with_stats_log(keys, marshal=true)
      if keys.is_a? Array
        results = $stats.measure(:memcache) do
          get_without_stats_log(keys, marshal)
        end
        
        results.each do |result|
          if result.nil?
            $stats.incr(:memcache_misses)
          else
            $stats.incr(:memcache_hits)
          end
        end
        
        return results
      else
        result = $stats.measure(:memcache) do
          get_without_stats_log(keys, marshal)
        end
        
        if result.nil?
          $stats.incr(:memcache_misses)
        else
          $stats.incr(:memcache_hits)
        end
        
        return result
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