lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sugoi_pretty_json/version'

Gem::Specification.new do |spec|
  spec.name          = "sugoi_pretty_json"
  spec.version       = SugoiPrettyJSON::VERSION
  spec.authors       = ["jiikko"]
  spec.email         = ["n905i.1214@gmail.com"]

  spec.summary       = %q{pretty print log.}
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/jiikko/sugoi_pretty_json"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "awesome_print"
  spec.add_dependency "user_agent_parser"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"
end
