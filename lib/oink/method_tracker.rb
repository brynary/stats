module Oink
  module MethodTracker

    def add_method_timer(timer, method_name)
      class_eval <<-SRC, __FILE__, __LINE__
        def #{method_name}_with_stats_timer(*args, &block)
          Oink.measure(#{timer.inspect}) do
            #{method_name}_without_stats_timer(*args, &block)
          end
        end
        alias_method_chain #{method_name.inspect}, :stats_timer
      SRC
    end

    def add_method_incr(incr_name, method_name)
      class_eval <<-SRC, __FILE__, __LINE__
        def #{method_name}_with_stats_incr_#{incr_name}(*args, &block)
          Oink.incr(#{incr_name.inspect})
          #{method_name}_without_stats_incr_#{incr_name}(*args, &block)
        end
        alias_method_chain #{method_name.inspect}, :stats_incr_#{incr_name}
      SRC
    end

  end
end