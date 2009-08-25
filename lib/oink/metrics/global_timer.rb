require "benchmark"

module Oink
  module Metrics

    class GlobalTimer < Timer

      def initialize
      end

      def start
        @t0, @r0 = Benchmark.times, Time.now
      end

      def stop
        t1, r1 = Benchmark.times, Time.now
        @tms = Benchmark::Tms.new(t1.utime - @t0.utime,
                           t1.stime  - @t0.stime,
                           t1.cutime - @t0.cutime,
                           t1.cstime - @t0.cstime,
                           r1.to_f - @r0.to_f)
      end

      def name
        :time
      end

      def field_names
        ["usr_time", "sys_time", "real_time"]
      end

    end
  end
end