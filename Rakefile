require 'rubygems'
require 'grancher/task'
require 'rake'
require 'rake/testtask'
require 'jekyll'
require 'serve'
require 'launchy'
require 'directory_watcher'

Grancher::Task.new do |g|
  g.branch = 'gh-pages'
  g.push_to = 'origin'
  g.message = "Updated website"

  g.directory 'site'
end

Rake::TestTask.new do |t|
  t.libs << "ruby/test" << "ruby/lemur"
  t.test_files = FileList['ruby/test/*_test.rb']
  t.verbose = true
end

task :default => :test

namespace :site do
  
  desc "Autogenerate site"
  task :auto do
    Jekyll.pygments = true
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
    
    Launchy.open("http://localhost:4000/lemur-scheme/")
    
    Serve::Application.run(['/tmp'])
  end
end

def globs(source)
  Dir.chdir(source) do
    dirs = Dir['*'].select { |x| File.directory?(x) }
    dirs -= ['_site']
    dirs = dirs.map { |x| "#{x}/**/*" }
    dirs += ['*']
  end
end
