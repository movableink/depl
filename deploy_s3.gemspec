$:.push File.expand_path("../lib", __FILE__)
require "deploy_s3/version"

Gem::Specification.new do |s|
  s.name        = "deploy_s3"
  s.version     = DeployS3::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Michael Nutt"]
  s.email       = ["michael@movableink.com"]
  s.homepage    = "https://github.com/movableink/deploy_s3"
  s.summary     = %q{Writes project deployment hash to s3 file}
  s.licenses    = "MIT"
  s.description = %q{Separate out the deployment concerns from your application by using deploy_s3 to write your latest deployed git hash to s3. Then let your provisioning system (for instance, chef + deploy_revision provider) take care of actually deploying new code. deploy_s3 shows diffs between your current branch and the deployed revision.}

  s.add_runtime_dependency "fog", "~> 1.25"
  s.add_runtime_dependency "highline", "~> 1.6"
  s.add_runtime_dependency "colorize", "~> 0.7"

  s.add_development_dependency "rspec", "~> 2.5"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
