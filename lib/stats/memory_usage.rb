class Stats
  class MemoryUsage
    def self.kilobytes
      `ps -o rss= -p #{$$}`.to_i
    end
  end
end