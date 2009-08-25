require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require "time"
require "benchmark"

describe Oink, "for Rails" do
  def app
    Oink::Middleware.new(sample_app, $stats)
  end

  def sample_app
    proc do |env|
      [200, {"Content-Type" => "text/html"}, ["OK"]]
    end
  end

  describe "HTTP" do
    before do
      $stats = Oink::Log.new($log, [:uri, :http_method, :response_code])
    end

    it "stores the URI" do
      get "/path"
      $log.should have_value(:uri, "/path")
    end

    it "stores the HTTP method" do
      put "/"
      $log.should have_value(:http_method, "PUT")
    end

    it "stores the response code" do
      get "/"
      $log.should have_value(:response_code, "200")
    end
  end

  describe "routing" do
    before do
      $stats = Oink::Log.new($log, [:controller_name, :action_name])
    end

    it "stores the controller name" do
      get "/", {}, { "rack.routing_args" => { "controller" => "sessions" } }
      $log.should have_value(:controller_name, "sessions")
    end

    it "stores the action name" do
      get "/", {}, { "rack.routing_args" => { "action" => "new" } }
      $log.should have_value(:action_name, "new")
    end
  end

  describe "SQL" do
    before do
      $stats = Oink::Log.new($log)
    end

    def connection
      @connection ||= ActiveRecord::ConnectionAdapters::AbstractAdapter.new
    end

    it "stores the query count" do
      $stats.transaction do
        connection.log("SELECT 1", "")
        connection.log("SELECT 2", "")
      end

      $log.should have_value(:sql_queries, "2")
    end

    it "stores the user CPU time" do
      Benchmark.stub!(:measure).and_yield.and_return(Benchmark::Tms.new(0.5))

      $stats.transaction do
        connection.log("SELECT 1", "")
        connection.log("SELECT 1", "")
      end

      $log.should have_value(:sql_usr_time, "1000")
    end

    it "stores the system CPU time" do
      Benchmark.stub!(:measure).and_yield.and_return(Benchmark::Tms.new(0.0, 0.5))

      $stats.transaction do
        connection.log("SELECT 1", "")
        connection.log("SELECT 1", "")
      end

      $log.should have_value(:sql_sys_time, "1000")
    end

    it "stores the real time" do
      Benchmark.stub!(:measure).and_yield.and_return(Benchmark::Tms.new(0.0, 0.0, 0.0, 0.0, 0.5))

      $stats.transaction do
        connection.log("SELECT 1", "")
        connection.log("SELECT 1", "")
      end

      $log.should have_value(:sql_real_time, "1000")
    end
  end

  describe "Memcached" do
    before do
      $stats = Oink::Log.new($log)
    end

    it "stores the hits count" do
      $stats.transaction do
        memcached = Memcached.new
        memcached.stub!(:get_without_stats_log).and_return("1", { "key2" => "2", "key3" => "3" })
        memcached.get "key1"
        memcached.get ["key2", "key3"]
      end

      $log.should have_value(:memcache_hits, "3")
      $log.should have_value(:memcache_misses, "-")
    end

    it "stores the misses count for single gets" do
      $stats.transaction do
        memcached = Memcached.new
        memcached.stub!(:get_without_stats_log).and_raise(Memcached::NotFound)

        lambda do
          memcached.get "key1"
        end.should raise_error(Memcached::NotFound)
      end

      $log.should have_value(:memcache_misses, "1")
      $log.should have_value(:memcache_hits, "-")
    end

    it "stores the misses count for multigets" do
      $stats.transaction do
        memcached = Memcached.new
        memcached.stub!(:get_without_stats_log => {})
        memcached.get ["key2", "key3"]
      end

      $log.should have_value(:memcache_misses, "2")
      $log.should have_value(:memcache_hits, "-")
    end

    it "stores the writes count" do
      $stats.transaction do
        memcached = Memcached.new
        memcached.decrement "key"
        memcached.increment "key"
        memcached.replace "key", "value"
        memcached.prepend "key", "value"
        memcached.append "key", "value"
        memcached.delete "key"
        memcached.set "key", "value"
        memcached.add "key", "value"
        memcached.get "key"
      end

      $log.should have_value(:memcache_writes, "8")
    end

    it "stores the user CPU time" do
      Benchmark.stub!(:measure).and_yield.and_return(Benchmark::Tms.new(0.5))

      $stats.transaction do
        memcached = Memcached.new
        memcached.get "key"
        memcached.get "key"
      end

      $log.should have_value(:memcache_usr_time, "1000")
    end

    it "stores the system CPU time" do
      Benchmark.stub!(:measure).and_yield.and_return(Benchmark::Tms.new(0.0, 0.5))

      $stats.transaction do
        memcached = Memcached.new
        memcached.decrement "key"
        memcached.increment "key"
      end

      $log.should have_value(:memcache_sys_time, "1000")
    end

    it "stores the real time" do
      Benchmark.stub!(:measure).and_yield.and_return(Benchmark::Tms.new(0.0, 0.0, 0.0, 0.0, 0.5))

      $stats.transaction do
        memcached = Memcached.new
        memcached.decrement "key"
        memcached.increment "key"
      end

      $log.should have_value(:memcache_real_time, "1000")
    end
  end

  describe "ActiveRecord" do
    before do
      $stats = Oink::Log.new($log)
    end

    it "stores the number of instantiated AR objects" do
      active_record = ActiveRecord::Base.new

      $stats.transaction do
        active_record.after_initialize
        active_record.after_initialize
      end

      $log.should have_value(:active_record_instances, "2")
    end
  end

end
