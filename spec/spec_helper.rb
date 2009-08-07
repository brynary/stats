require "rubygems"
require "spec"
require "active_support"

require File.dirname(File.dirname(__FILE__)) + '/spec/fixtures/memcached'
require File.dirname(File.dirname(__FILE__)) + '/spec/fixtures/abstract_adapter'
require File.dirname(File.dirname(__FILE__)) + '/spec/fixtures/active_record'

$LOAD_PATH.unshift File.dirname(File.dirname(__FILE__)) + '/lib'
require "oink"
require "rack/test"
require "fastercsv"

class LogParser
  def initialize(log_lines)
    @lines = log_lines
  end

  def parsed_lines
    FasterCSV.parse(lines_without_directives.join("\n"), :col_sep => " ")
  end

  def field_exists?(name)
    !fields.index(name.to_s).nil?
  end

  def last_value(name)
    parsed_lines.last[fields.index(name.to_s)]
    # @lines.last.split(" ")[fields.index(name.to_s)]
  end

  def fields
    @lines.grep(/# Fields:/).first.gsub(/^# Fields: /, '').split(" ")
  end

  def lines_without_directives
    @lines.grep(/^[^#]/)
  end
end

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

  def include?(message)
    @lines.include?(message)
  end

  def field_exists?(name)
    parser.field_exists?(name)
  end

  def last_value(name)
    parser.last_value(name)
  end

  def parser
    @parser ||= LogParser.new(@lines)
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
      log.field_exists?(name) && expected_value == log.last_value(name)
    end

    failure_message_for_should do |log|
      if log.field_exists?(name)
        actual_value = log.last_value(name)
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