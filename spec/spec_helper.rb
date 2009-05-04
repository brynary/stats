require "spec"
require "active_support"

require File.dirname(File.dirname(__FILE__)) + '/spec/fixtures/memcached'
require File.dirname(File.dirname(__FILE__)) + '/spec/fixtures/abstract_adapter'
require File.dirname(File.dirname(__FILE__)) + '/spec/fixtures/active_record'

$LOAD_PATH.unshift File.dirname(File.dirname(__FILE__)) + '/lib'
require "stats"
require "rack/test"

class DummyLogger
  def initialize
    @lines = []
  end

  def info(message)
    @lines << message
  end

  def lines
    @lines
  end

  def fields
    @lines.grep(/# Fields:/).first.gsub(/^# Fields: /, '').split(" ")
  end

  def include?(message)
    @lines.include?(message)
  end
end

def Time.freeze(now)
  Time.stub!(:now => now)
  yield if block_given?
end

Spec::Runner.configure do |config|
  config.include Rack::Test::Methods

  config.before do
    $log = DummyLogger.new
  end

  Spec::Matchers.define :have_value do |name, expected_value|
    match do |log|
      fields = log.fields
      index = fields.index(name.to_s)

      if index
        actual_value = log.lines.last.split(" ")[index]
        expected_value == actual_value
      else
        false
      end
    end

    failure_message_for_should do |log|
      fields = log.fields
      index = fields.index(name.to_s)

      if index
        actual_value = log.lines.last.split(" ")[index]
        "expected proc to log the value #{expected_value.inspect} for #{name} but got: #{actual_value.inspect}"
      else
        "expected proc to log the value #{expected_value.inspect} for #{name} but field not found"
      end
    end
  end

  def have_directive(name, value)
    expected_line = "# " + name + ": " + value
    simple_matcher "log directive: #{expected_line}" do |log|
      log.include?(expected_line)
    end
  end

end