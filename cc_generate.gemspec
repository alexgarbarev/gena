Gem::Specification.new do |s|
  s.name        = 'cc_generate'
  s.version     = '0.0.3'
  s.date        = '2016-12-16'
  s.summary     = "iOS code generation tool"
  s.description = "Depends on Generamba it generates templates for generamba :)"
  s.authors     = ["Aleksey Garbarev"]
  s.email       = 'alex.garbarev@gmail.com'
  s.files       = ["lib/base_template.rb",
                   "lib/config.rb",
                   "lib/ramba_adapter.rb",
                   "lib/cc_generate.rb",
                   "lib/generate_cli.rb",
                   "lib/string_utils.rb"]
  s.homepage    =
    'http://rubygems.org/gems/cc_generate'
  s.license       = 'MIT'
  s.executables << 'gena'
  s.add_runtime_dependency 'generamba', '>= 1.3.0'
  s.add_runtime_dependency 'plist'
  s.add_runtime_dependency 'ttfunk'
end