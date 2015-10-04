Gem::Specification.new do |s|
  s.name        = "mongoid_alize"
  s.version     = "0.5.0"
  s.author      = "Josh Dzielak"
  s.email       = "github_public@dz.oib.com"
  s.homepage    = "https://github.com/dzello/mongoid_alize"
  s.summary     = "Comprehensive field denormalization for Mongoid that stays in sync."
  s.description = "Keep data in sync as you denormalize across any type of relation."
  s.license     = "MIT"

  s.files        = Dir["{config,lib,spec}/**/*"] - ["Gemfile.lock"]
  s.require_path = "lib"

  s.add_dependency 'mongoid', ">= 2.4"
  s.add_development_dependency 'rspec', '~> 2.6.0'
end
