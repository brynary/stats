module Oink
  module Formatter
    def self.format_value(value)
      case value
      when nil
        "-"
      when Float
        "%.2f" % value
      when Time
        value.strftime("%T")
      when String
        quote(value)
      else
        value.to_s
      end
    end

    def self.quote(value)
      '"'                               +
      String(value).gsub('"', '"' * 2)  +
      '"'
    end
  end
end