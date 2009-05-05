require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require "time"

describe Stats do
  
  describe "logging headers" do
    it "records the field list" do
      Stats.new([:user_id], $log)
      $log.should have_directive("Fields", "transaction date time usr_time sys_time real_time user_id")
    end

    it "records the start date" do
      Time.freeze(Time.parse("2009-01-04 11:22:33 -0000")) do
        Stats.new([:user_id], $log)
        $log.should have_directive("Start-Date", "2009-01-04 11:22:33")
      end
    end

    it "records the start date as UTC" do
      Time.freeze(Time.parse("2009-01-04 11:22:33 -0300")) do
        Stats.new([:user_id], $log)
        $log.should have_directive("Start-Date", "2009-01-04 14:22:33")
      end
    end
  end

  describe "logging stats" do
    before do
      $stats = Stats.new(%w[user_id], $log)
    end

    it "stores a transaction id" do
      now = Time.now
      Time.stub!(:now => now)
      ActiveSupport::SecureRandom.stub!(:hex => "abcd")
      $stats.transaction do
        # Nothing
      end
      
      $log.should have_value(:transaction, "#{now.to_i}-abcd")
    end

    it "stores the date" do
      Time.freeze(Time.parse("2009-01-04 11:22:33 -0000")) do
        $stats.transaction do
          # Nothing
        end
        
        $log.should have_value(:date, "2009-01-04")
      end
    end

    it "stores the time" do
      Time.freeze(Time.parse("2009-01-04 11:22:33 -0000")) do
        $stats.transaction do
          # Nothing
        end
        
        $log.should have_value(:time, "11:22:33")
      end
    end

    it "stores the time in UTC" do
      Time.freeze(Time.parse("2009-01-04 11:22:33 -0300")) do
        $stats.transaction do
          # Nothing
        end
        
        $log.should have_value(:time, "14:22:33")
      end
    end

    it "stores additional provided values" do
      $stats.transaction do
        $stats[:user_id] = 10
      end
      
      $log.should have_value(:user_id, "10")
    end

    it "clears values between transactions" do
      $stats.transaction do
        $stats[:user_id] = 10
      end

      $stats.transaction do
        # Nothing
      end
      
      $log.should have_value(:user_id, "-")
    end

    it "logs dashes for missing values" do
      $stats.transaction do
        # Nothing
      end
      
      $log.should have_value(:user_id, "-")
    end
  end
  
  describe "resource usage" do
    before do
      $stats = Stats.new([], $log)
    end

    it "stores the user CPU time" do
      Benchmark.stub!(:measure).and_yield.and_return(Benchmark::Tms.new(0.5))
      $stats.transaction do
        # Nothing
      end
      $log.should have_value(:usr_time, "500.0")
    end

    it "stores the system CPU time" do
      Benchmark.stub!(:measure).and_yield.and_return(Benchmark::Tms.new(0.0, 0.5))
      $stats.transaction do
        # Nothing
      end
      $log.should have_value(:sys_time, "500.0")
    end

    it "stores the total wall time" do
      Benchmark.stub!(:measure).and_yield.and_return(Benchmark::Tms.new(0.0, 0.0, 0.0, 0.0, 0.5))
      $stats.transaction do
        # Nothing
      end
      $log.should have_value(:real_time, "500.0")
    end
  end

  describe "memory usage" do
    before do
      $stats = Stats.new([:memory, :memory_delta], $log)
    end

    it "stores the process memory size change in KB" do
      Stats::MemoryUsage.stub!(:kilobytes => 16_121)
      $stats.transaction do
        # Nothing
      end
      $log.should have_value(:memory, "16121")
    end

    it "stores the process memory size in KB" do
      Stats::MemoryUsage.stub!(:kilobytes).and_return(16_121, 16_021)
      $stats.transaction do
        # Nothing
      end
      $log.should have_value(:memory_delta, "-100")
    end
  end
end