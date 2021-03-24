# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "knapsack_pro"
  spec.version       = "1.0.0"
  spec.authors       = ['ArturT']
  spec.email         = ['arturtrzop@gmail.com']
  spec.summary       = %q{Knapsack Pro splits tests across parallel CI nodes and ensures each parallel job finish work at a similar time.}
  spec.description   = %q{Run tests in parallel across CI server nodes based on tests execution time. Split tests in a dynamic way to ensure parallel jobs are done at a similar time. Thanks to that your CI build time is as fast as possible. It works with many CI providers.}
  spec.homepage      = 'https://knapsackpro.com'
  spec.license       = 'MIT'
  spec.metadata    = {
    'bug_tracker_uri' => 'https://github.com/KnapsackPro/knapsack_pro-ruby/issues',
    'changelog_uri' => 'https://github.com/KnapsackPro/knapsack_pro-ruby/blob/master/CHANGELOG.md',
    'documentation_uri' => 'https://docs.knapsackpro.com/integration/',
    'homepage_uri' => 'https://knapsackpro.com',
    'source_code_uri' => 'https://github.com/KnapsackPro/knapsack_pro-ruby'
  }

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'rake', '>= 0'
  spec.add_dependency 'redis', '>= 3.2.0'
  spec.add_dependency 'rspec', '~> 3.0', '>= 2.10.0'

  spec.add_development_dependency 'bundler', '>= 1.6'
  spec.add_development_dependency 'rspec-its', '~> 1.2'
  spec.add_development_dependency 'timecop', '>= 0.1.0'
end
