# promptspec.gemspec
Gem::Specification.new do |spec|
  spec.name          = "promptspec"
  spec.version       = "0.0.4"
  spec.authors       = ["Hyperaide, John Paul, Daniel Paul"]
  spec.email         = ["jp@hyperaide.com"]

  spec.summary       = %q{A gem to manage prompts in YAML files.}
  spec.description   = %q{This gem allows developers to manage and call AI prompts stored in YAML files.}
  spec.homepage      = "https://promptspec.com"
  spec.license       = "MIT"

  spec.files         = ["lib/promptspec.rb", "promptspec.gemspec", "README.md"]
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "yaml", "~> 0.1.0"
  spec.add_runtime_dependency "erb", "~> 2.2.0"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
end
