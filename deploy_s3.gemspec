$:.push File.expand_path("../lib", __FILE__)
require "deploy_s3/version"

Gem::Specification.new do |s|
  s.name        = "deploy_s3"
  s.version     = DeployS3::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Michael Nutt"]
  s.email       = ["michael@movableink.com"]
  s.homepage    = ""
  s.summary     = %q{Writes project deployment hash to s3 file}
  s.description = %q{Writes project deployment hash to s3 file}

  s.add_runtime_dependency "fog", "~>1.25.0"
  s.add_development_dependency "rspec", "~>2.5.0"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
