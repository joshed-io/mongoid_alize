Gem::Specification.new do |s|
  s.name        = "mongoid_alize"
  s.version     = "0.2.0"
  s.author      = "Josh Dzielak"
  s.email       = "github_public@dz.oib.com"
  s.homepage    = "https://github.com/dzello/mongoid_alize"
  s.summary     = "Comprehensive, synchronized denormalization for Mongoid."
  s.description = "Keep data in sync as you denormalize across any type of relation."

  s.files        = Dir["{lib,spec}/**/*"] - ["Gemfile.lock"]
  s.require_path = "lib"

  s.add_dependency 'mongoid'
  s.add_development_dependency 'rspec', '~> 2.6.0'
end
