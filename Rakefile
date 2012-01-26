require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'grancher/task'
require 'jekyll'
require 'serve'
require 'directory_watcher'

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
    test_cmd = "bin/lemur test/r4rs.scm"
    puts test_cmd
    puts `#{test_cmd}`
  end
end

desc "GitHub site"
namespace 'site' do
  Grancher::Task.new do |g|
    g.branch = 'gh-pages'
    g.push_to = 'origin'
    g.message = "Updated website"

    g.directory 'site'
  end

  desc "Autogenerate site"
  task :auto do
    Jekyll.pygments = RUBY_PLATFORM !~ /java/
    source = File.join(File.dirname(__FILE__), '/site')
    destination = '/tmp/lemur-scheme'

    system("rm -r #{destination}")
    puts "Auto-regenerating enabled: #{source} -> #{destination}"

    dw = DirectoryWatcher.new(source)
    dw.interval = 1
    dw.glob = globs(source)

    dw.add_observer do |*args|
      t = Time.now.strftime("%Y-%m-%d %H:%M:%S")
      puts "[#{t}] regeneration: #{args.size} files changed"
      Jekyll.process(source, destination)
    end

    dw.start

    Serve::Application.run(['/tmp'])
  end

  def globs(source)
    Dir.chdir(source) do
      dirs = Dir['*'].select { |x| File.directory?(x) }
      dirs -= ['_site']
      dirs = dirs.map { |x| "#{x}/**/*" }
      dirs += ['*']
    end
  end
end
