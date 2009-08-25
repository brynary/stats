module Oink
  module Metrics
    module Extensions
      module ActiveRecord
        def self.add_to(log)
          if defined?(ActiveRecord)
            log.add Counter.new(:active_record_instances)
            log.add Counter.new(:sql_queries)
            log.add Timer.new(:sql)
          end
        end
      end
    end
  end
end

if defined?(ActiveRecord)
  ActiveRecord::Base.class_eval do
    extend Oink::MethodTracker

    unless instance_methods.include?("after_initialize")
      def after_initialize
      end
    end

    add_method_incr :active_record_instances, :after_initialize
  end

  ActiveRecord::ConnectionAdapters::AbstractAdapter.class_eval do
    extend Oink::MethodTracker

    add_method_incr :sql_queries, :log
    add_method_timer :sql, :log
  end
end