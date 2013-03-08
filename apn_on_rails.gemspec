# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "apn_on_rails/version"

Gem::Specification.new do |s|
  s.name = %q{apn_on_rails}
  s.version = APN::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors = ["markbates", "Rebecca Nesson"]
  s.date = %q{2011-01-04}
  s.description = %q{APN on Rails is a Ruby on Rails gem that allows you to easily add Apple Push Notification (iPhone) support to your Rails application.}
  s.email = %q{tech-team@prx.org}
  s.files         = `git ls-files`.split("\n")
  s.require_paths = ["lib"]
end

