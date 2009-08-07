require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require "time"

describe Oink do
  describe "logging headers" do
    it "records the field list" do
      Oink::Log.new([:user_id], $log)
      $log.should have_directive("Fields", "transaction date time usr_time sys_time real_time user_id")
    end

    it "records the start date" do
      Time.freeze(Time.parse("2009-01-04 11:22:33 -0000")) do
        Oink::Log.new([:user_id], $log)
        $log.should have_directive("Start-Date", "2009-01-04 11:22:33")
      end
    end

    it "records the start date as UTC" do
      Time.freeze(Time.parse("2009-01-04 11:22:33 -0300")) do
        Oink::Log.new([:user_id], $log)
        $log.should have_directive("Start-Date", "2009-01-04 14:22:33")
      end
    end
  end

  describe "logging stats" do
    before do
      $stats = Oink::Log.new(%w[custom_field], $log)
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

    it "stores additional provided integer values" do
      $stats.transaction do
        $stats[:custom_field] = 10
      end

      $log.should have_value(:custom_field, "10")
    end

    it "stores additional provided float values with two decimal places" do
      $stats.transaction do
        $stats[:custom_field] = 10.123123213
      end

      $log.should have_value(:custom_field, "10.12")
    end

    it "stores additional provided string values with quotes" do
      $stats.transaction do
        $stats[:custom_field] = "foo bar"
      end

      $log.should have_value(:custom_field, "foo bar")
    end

    it "escapes quotes in strings" do
      $stats.transaction do
        $stats[:custom_field] = "foo\" bar"
      end

      $log.should have_value(:custom_field, "foo\" bar")
    end

    it "clears values between transactions" do
      $stats.transaction do
        $stats[:custom_field] = 10
      end

      $stats.transaction do
        # Nothing
      end

      $log.should have_value(:custom_field, "-")
    end

    it "logs dashes for missing values" do
      $stats.transaction do
        # Nothing
      end

      $log.should have_value(:custom_field, "-")
    end
  end

  describe "resource usage" do
    before do
      $stats = Oink::Log.new([], $log)
    end

    it "stores the user CPU time" do
      Benchmark.stub!(:measure).and_yield.and_return(Benchmark::Tms.new(0.5))
      $stats.transaction do
        # Nothing
      end
      $log.should have_value(:usr_time, "500.00")
    end

    it "stores the system CPU time" do
      Benchmark.stub!(:measure).and_yield.and_return(Benchmark::Tms.new(0.0, 0.5))
      $stats.transaction do
        # Nothing
      end
      $log.should have_value(:sys_time, "500.00")
    end

    it "stores the total wall time" do
      Benchmark.stub!(:measure).and_yield.and_return(Benchmark::Tms.new(0.0, 0.0, 0.0, 0.0, 0.5))
      $stats.transaction do
        # Nothing
      end
      $log.should have_value(:real_time, "500.00")
    end
  end

  describe "multiple stats objects" do
    before do
      $main_log = DummyLogger.new
      $main_stats = Oink::Log.new([:custom_field], $main_log)

      $other_log = DummyLogger.new
      $other_stats = Oink::Log.new([:custom_field], $other_log)
    end

    it "sends values to both stats with open transactions" do
      $main_stats.transaction do
        $other_stats.transaction do
          Oink::Stats.broadcaster[:custom_field] = "10"

          $other_stats[:custom_field].should == "10"
          $main_stats[:custom_field].should == "10"
        end
      end
    end

    it "doesn't send values to a stats object not in a transaction" do
      $main_stats.transaction do
        $other_stats.transaction do
        end

        Oink::Stats.broadcaster[:custom_field] = "10"

        $other_stats[:custom_field].should be_nil
        $main_stats[:custom_field].should == "10"
      end
    end
  end
end