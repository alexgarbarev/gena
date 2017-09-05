
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.pattern = "test/test_*"
  t.warning = false
end

desc "Run tests"
task :default => :test