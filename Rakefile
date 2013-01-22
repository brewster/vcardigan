require File.dirname(__FILE__) + '/lib/vcardigan/version'

task :build do
  system "gem build vcardigan.gemspec"
end

task :release do
  system "git tag -am 'Version #{VCardigan::VERSION}' #{VCardigan::VERSION}"
  system "git push origin --tags"
  system "gem push vcardigan-#{VCardigan::VERSION}.gem"
end
