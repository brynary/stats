module Oink
  module Metrics

    class Change < Metric

      def initialize(name, metric)
        @name = name
        @metric = metric
      end

      def start
        @initial = @metric.values
      end

      def stop
        @final = @metric.values
      end

      def field_names
        @metric.field_names
      end

      def values
        result = []

        @final.each_with_index do |value, i|
          result << value - @initial[i]
        end

        result
      end

    end
  end
end