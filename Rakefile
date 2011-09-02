require 'bundler'
require 'rspec/core/rake_task'
Bundler::GemHelper.install_tasks

RSpec::Core::RakeTask.new(:spec)

desc "runs specs on ruby 1.9.2 and ruby 1.8.7"
task :spec_rubies do
	system "rvm ruby-1.9.2-p180@databasedotcom,ruby-1.8.7-p302@databasedotcom --create rake spec"
end

task :default => :spec
