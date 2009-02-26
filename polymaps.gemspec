# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{polymaps}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["cornflakesuperstar"]
  s.date = %q{2009-02-27}
  s.description = %q{Polymaps lets you overlay clickable polygons on top of a google map with your specified geo-coded regions}
  s.email = %q{cornflakesuperstar@hotmail.com}
  s.files = ["VERSION.yml", "lib/poly_maps.rb", "lib/poly_maps.js", "lib/country_centers_and_zooms.yml"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/cornflakesuperstar/polymaps}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Polymaps lets you overlay clickable polygons on top of a google map with your specified geo-coded regions}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
