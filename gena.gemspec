
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'constants'

Gem::Specification.new do |s|
  s.name        = 'gena'
  s.version     = Gena::VERSION
  s.date        = Gena::RELEASE_DATE
  s.summary     = "iOS code generation tool"
  s.description = "Code generation and automation tool"
  s.authors     = ["Aleksey Garbarev"]
  s.email       = 'alex.garbarev@gmail.com'
  s.files       = [ "lib/gena.rb",
                    "lib/config/config.rb",
                    "lib/plugin/plugin.rb",
                    "lib/utils/utils.rb",
                    "lib/utils/xcode_utils.rb",
                    "lib/cli/init.rb",
                    "lib/cli/cli.rb",
                    "lib/codegen/codegen.rb",
                    "lib/constants.rb"]
  s.homepage    =
    'http://rubygems.org/gems/gena'
  s.license       = 'MIT'
  s.executables << 'gena'
  s.add_runtime_dependency 'xcodeproj', '~> 1.5', '>= 1.5.2'
  s.add_runtime_dependency 'thor', '~> 0.20', '>= 0.20.0'
  s.add_runtime_dependency 'liquid', '~> 4.0', '>= 4.0.0'
  s.add_runtime_dependency 'plist', '~> 3.2', '>= 3.2.0'
  s.add_runtime_dependency 'ttfunk', '~> 1.4', '>= 1.4.0'
end