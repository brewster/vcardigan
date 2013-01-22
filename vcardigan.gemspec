require File.dirname(__FILE__) + '/lib/vcardigan/version'

spec = Gem::Specification.new do |s|
  s.name = 'vcardigan'
  s.version = VCardigan::VERSION
  s.author = 'Matt Morgan'
  s.email = 'matt@mlmorg.com'
  s.license = 'MIT'
  s.summary = 'Ruby vCard Builder/Parser'
  s.description = 'vCardigan is a ruby library for building and parsing vCards that supports both v3.0 and v4.0.'
  s.homepage = 'http://github.com/brewster/vcardigan'
  s.files = Dir['lib/**/*.rb']
  s.has_rdoc = false
end
