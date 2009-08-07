require "rubygems"
require "spec/rake/spectask"

begin
  require 'jeweler'

  Jeweler::Tasks.new do |s|
    s.name      = "oink"
    s.authors   = ["Noah Davis", "Bryan Helmkamp"]
    s.email     = ["noahd1" + "@" + "yahoo.com", "bryan" + "@" + "brynary.com"]
    s.homepage  = "http://github.com/noahd1/oink"
    s.summary   = "Collect metrics from your production app to analyze later"
    s.extra_rdoc_files = %w[README.rdoc]
  end

  # Jeweler::RubyforgeTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end

Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ['--options', "\"#{File.dirname(__FILE__)}/spec/spec.opts\""]
end

task :spec => :check_dependencies

desc "Run the specs"
task :default => :spec