# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "apns_on_rails/version"

Gem::Specification.new do |s|
  s.name = %q{apns_on_rails}
  s.version = APNS::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["Spencer MacDonald"]
  s.date = %q{2013-03-08}
  s.description = %q{APNS on Rails is a lightweight gem that adds support for the Apple Push Notification Service to your Rails application.}
  s.email = %q{opensource@squarebracketsoftware.com}
  s.files = `git ls-files`.split("\n")
  s.require_paths = ["lib"]
end

