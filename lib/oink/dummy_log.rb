module Oink
  class DummyLog

    def metric(name)
    end

    def []=(key, value)
    end

    def transaction
      yield
    end

  end
end