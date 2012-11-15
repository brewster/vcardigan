require File.dirname(__FILE__) + '/lib/vcard_mate/version'

task :build do
  system "gem build vcard_mate.gemspec"
end

task :release do
  system "git tag -am 'Version #{VCardMate::VERSION}' #{VCardMate::VERSION}"
  system "git push origin --tags"
  system "gem push vcard_mate-#{VCardMate::VERSION}.gem"
end
