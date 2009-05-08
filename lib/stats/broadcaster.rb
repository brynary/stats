class Stats

  class Broadcaster
    instance_methods.each { |m| undef_method m unless m =~ /^__/ }
    include Measure

    def initialize(receivers = [])
      @receivers = receivers
    end

    def method_missing(method_name, *args, &block)
      @receivers.map do |receiver|
        receiver.__send__(method_name, *args, &block)
      end
    end
  end

end