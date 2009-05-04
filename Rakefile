require "spec/rake/spectask"

$LOAD_PATH.unshift File.dirname(__FILE__) + '/lib'
require "stats"

Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ['--options', "\"#{File.dirname(__FILE__)}/spec/spec.opts\""]
end

desc "Run the specs"
task :default => :spec