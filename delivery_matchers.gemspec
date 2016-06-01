# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'delivery_matchers/version'

Gem::Specification.new do |spec|
  spec.name          = "delivery_matchers"
  spec.version       = DeliveryMatchers::VERSION
  spec.authors       = ["General Assembly"]
  spec.email         = ["opensource@generalassemb.ly"]

  spec.summary       = "RSpec custom matchers for ActionMailer's deliver_later"
  spec.homepage      = "https://github.com/generalassembly/delivery_matchers"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rspec", ">= 3.0"
  spec.add_dependency "actionmailer", ">= 4.2", "< 5.1"
  spec.add_dependency "activejob", ">= 4.2", "< 5.1"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
end
