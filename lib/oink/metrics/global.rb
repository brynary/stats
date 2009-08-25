module Oink
  module Metrics

    class Global < Metric

      def initialize(name, &block)
        @name = name
        @measurer = block
      end

      def field_names
        [@name]
      end

      def values
        [@measurer.call]
      end

    end

  end
end