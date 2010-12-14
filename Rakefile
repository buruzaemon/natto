require 'rubygems' if RUBY_VERSION.to_f < 1.9
require 'rake'
require 'rake/gempackagetask'

spec = Gem::Specification.new do |s|
  s.author = 'Brooke M. Fujita'
  s.add_dependency('ffi', '>= 0.6.3')
  s.name = 'natto'
  s.version = '0.0.1'
  s.email = 'buruzaemon@gmail.com'
  s.homepage = 'http://code.google.com/p/natto/'
  s.license = 'BSD'
  s.platform = Gem::Platform::RUBY
  s.summary = 'natto combines the Ruby programming language with MeCab, the part-of-speech and morphological analyzer for the Japanese language.'
  s.requirements << 'none'
  s.required_ruby_version = '>= 1.8.7'
  s.require_path = 'lib'
  s.requirements << 'MeCab, 0.98 or greater'
  s.autorequire = 'natto'
  s.files = FileList['lib/**/*.rb', 'test/**/test_natto.rb', 'LICENSE']
  s.description = <<-EOF
    natto combines the Ruby programming language
    with MeCab, the part-of-speech and morphological
    analyzer for the Japanese language.
  EOF
  s.test_file  = 'test/test_natto.rb'
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

desc "Run unit tests"
task :test do 
  require 'rbconfig'
  sh "#{RbConfig::CONFIG['RUBY_INSTALL_NAME']} test/test_natto.rb"
end

task :default => [:test]
