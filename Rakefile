require 'bundler'
require 'rdoc/task'
require 'rspec/core/rake_task'
Bundler::GemHelper.install_tasks

RSpec::Core::RakeTask.new(:spec)

Rake::RDocTask.new do |rd|
  rd.rdoc_dir = "doc"
  rd.rdoc_files.include("lib/**/*.rb")
  rd.rdoc_files.include("README.rdoc")
  rd.rdoc_files.include("MIT-LICENSE")
  rd.main = "README.rdoc"
end

desc 'Default: run specs.'
task :default => :spec
