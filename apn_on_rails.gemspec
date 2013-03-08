# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "apn_on_rails/version"

Gem::Specification.new do |s|
  s.name = %q{apn_on_rails}
  s.version = APN::VERSION

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["markbates", "Rebecca Nesson"]
  s.date = %q{2011-01-04}
  s.description = %q{APN on Rails is a Ruby on Rails gem that allows you to easily add Apple Push Notification (iPhone) support to your Rails application.}
  s.email = %q{tech-team@prx.org}
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end

