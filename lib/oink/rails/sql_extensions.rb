if defined?(ActiveRecord)
  ActiveRecord::ConnectionAdapters::AbstractAdapter.class_eval do
    def log_with_stats_log(sql, name, &block)
      Oink::Stats.broadcaster.incr(:sql_queries)
      Oink::Stats.broadcaster.measure(:sql) do
        log_without_stats_log(sql, name, &block)
      end
    end

    alias_method_chain :log, :stats_log
  end
end