module Oink
  module Metrics

    class Counter < Metric

      def start
        @count = nil
      end

      def incr
        @count ||= 0
        @count += 1
      end

      def values
        [@count]
      end

    end

  end
end
