require 'rubygems'
require 'rake'
require 'rake/testtask'

LEMUR_HOME = File.dirname(__FILE__)

task :test => ['ruby:test', 'scheme:test']
task :default => :test

namespace :ruby do
  Rake::TestTask.new do |t|
    t.libs << "test" << "lib"
    t.test_files = FileList['test/*_test.rb']
    t.verbose = true
  end
end

namespace :scheme do
  desc "Run tests"
  task :test do
    test_cmd = "#{LEMUR_HOME}/bin/lemur test/tests.scm"
    puts test_cmd
    puts `#{test_cmd}`
  end

  desc "Run R4RS compliance tests"
  task :r4rs do
    test_cmd = "#{LEMUR_HOME}/bin/lemur test/r4rs.scm"
    puts test_cmd
    puts `#{test_cmd}`
  end
end
