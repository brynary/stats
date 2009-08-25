module Oink
  module Metrics

    class Metric
      attr_accessor :name

      def initialize(name)
        @name = name
      end

      def start
      end

      def stop
      end

      def field_names
        [@name]
      end

    end
  end
end