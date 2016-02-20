# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rswift/ios/version'

Gem::Specification.new do |spec|
  spec.name          = "rswift-ios"
  spec.version       = RSwift::IOS::VERSION
  spec.authors       = ["Lukasz Wolanczyk"]
  spec.email         = ['wolanczyk.lukasz@gmail.com']

  spec.summary       = 'Write a short summary, because Rubygems requires one.'
  spec.description   = 'Write a longer description or delete this line.'
  spec.homepage      = 'https://github.com/lukwol/rswift-ios'
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "Set to 'http://mygemserver.com'"
  else
    fail "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency 'byebug'
  spec.add_runtime_dependency 'rswift'
  spec.add_runtime_dependency 'rake'
  spec.add_runtime_dependency 'xcpretty'
end
