require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'grancher/task'
require 'jekyll'
require 'serve'
require 'directory_watcher'

desc "Lemur Scheme is a Scheme interpreter for the JVM using JRuby, Scala, and Java for its implementation"
define 'lemur' do
  manifest['Copyright'] = "(c) 2009 Clinton R. Nixon"
  
  desc "Ruby code"
  define 'ruby' do
    Rake::TestTask.new do |t|
      t.libs << "ruby/test" << "ruby/lib"
      t.test_files = FileList['ruby/test/*_test.rb']
      t.verbose = true
    end
  end
  
  desc "Scheme code"
  define 'scheme' do
    
    desc "Run tests"
    task :test do
      test_cmd = "#{project('lemur')._('ruby', 'lib', 'lemur')} #{_('tests.scm')}"
      puts test_cmd
      puts `#{project('lemur')._('ruby', 'lib', 'lemur.rb')} #{_('tests.scm')}`
    end
  end
  
  desc "GitHub site"
  define 'site' do
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
end
