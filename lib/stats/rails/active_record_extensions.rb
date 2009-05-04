if defined?(ActiveRecord)
  ActiveRecord::Base.class_eval do

    if instance_methods.include?("after_initialize")
      def after_initialize_with_stats_log
        $stats.incr(:active_record_instances)
        after_initialize_without_stats_log
      end
    
      alias_method_chain :after_initialize, :stats_log
    else
      def after_initialize
        $stats.incr(:active_record_instances)
      end
    end
    
  end
end