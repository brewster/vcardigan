require File.dirname(__FILE__) + '/lib/vcard_mate/version'

spec = Gem::Specification.new do |s|
  s.name = 'vcard_mate'
  s.version = VCardMate::VERSION
  s.author = 'Matt Morgan'
  s.email = 'matt@mlmorg.com'
  s.license = 'MIT'
  s.summary = 'Ruby vCard Builder/Parser'
  s.description = 'vCard Mate is a ruby library for building and parsing vCards that supports both v3.0 and v4.0.'
  s.homepage = 'http://github.com/mlmorg/vcard_mate'
  s.files = Dir['lib/**/*.rb']
  s.has_rdoc = false
end
