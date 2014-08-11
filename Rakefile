require File.dirname(__FILE__) + '/lib/vcardigan/version'
require 'rspec/core/rake_task'

task :release => [:test, :build, :tag, :push, :cleanup]

task :test do
  desc "Run tests"
  abort unless system 'bundle', 'exec', 'rspec', 'spec/examples'
end

task :build do
  desc 'Build gem'
  system "gem build vcardigan.gemspec"
end

task :tag do
  desc 'Push tags'
  system "git tag -am 'Version #{VCardigan::VERSION}' #{VCardigan::VERSION}"
  system "git push origin --tags"
end

task :push do
  desc 'Push gem to rubygems'
  system "gem push vcardigan-#{VCardigan::VERSION}.gem"
end

task :cleanup do
  desc 'Cleanup'
  system "rm -v *.gem"
end

task :default => [:test]
