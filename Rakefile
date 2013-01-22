require File.dirname(__FILE__) + '/lib/vcardigan/version'
require 'rspec/core/rake_task'

task :release => [:test, :build, :tag, :push, :cleanup]

task :test do
  abort unless system 'bundle', 'exec', 'rspec', 'spec/examples'
end

task :build do
  system "gem build vcardigan.gemspec"
end

task :tag do
  system "git tag -am 'Version #{VCardigan::VERSION}' #{VCardigan::VERSION}"
  system "git push origin --tags"
end

task :push do
  system "gem push vcardigan-#{VCardigan::VERSION}.gem"
end

task :cleanup do
  system "rm -v *.gem"
end
