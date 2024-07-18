# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "jekyll"
require "jekyll-ical-tag/version"

Gem::Specification.new do |spec|
  spec.name = "jekyll-ical-tag"
  spec.version = Jekyll::IcalTag::VERSION
  spec.authors = ["Ricky Chilcott"]
  spec.email = ["ricky@rakefire.io"]
  spec.summary = "A Jekyll plugin to pull ICS feed and provide a for-like loop of calendar events"
  spec.homepage = "https://github.com/rakefire/jekyll-ical-tag"
  spec.license = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.required_ruby_version = ">= 2.3.0"

  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r!^(test|spec|features)/!) }
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r!^exe/!) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "jekyll", "> 3"
  spec.add_dependency "api_cache"
  spec.add_dependency "activesupport", "~> 7.1"
  spec.add_dependency "icalendar", "~> 2.10.1"
  spec.add_dependency "icalendar-recurrence"

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rspec", "~> 3.5"
end
