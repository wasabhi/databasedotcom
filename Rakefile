require 'bundler'
require 'rspec/core/rake_task'
Bundler::GemHelper.install_tasks

RSpec::Core::RakeTask.new(:spec)

desc "runs specs on all supported rubies"
task :spec_rubies do
	system "rvm ruby-1.9.2-p180@databasedotcom,ruby-1.8.7-p357@databasedotcom,ruby-1.9.3@databasedotcom,ree@databasedotcom --create do rake spec"
end

task :default => :spec
