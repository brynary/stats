module ActiveRecord
  module ConnectionAdapters
    class AbstractAdapter
      def log(sql, name = nil)
      end
    end
  end
end