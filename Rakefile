# -*- coding: UTF-8 -*-
require 'rubygems' if RUBY_VERSION.to_f < 1.9
require 'rake'
require 'rake/gempackagetask'

spec = Gem::Specification.new do |s|
  s.name = 'natto'
  s.version = '0.0.2'
  s.add_dependency('ffi', '>= 0.6.3')
  s.license = 'BSD'
  s.summary = 'natto combines the Ruby programming language with MeCab, the part-of-speech and morphological analyzer for the Japanese language.'
  s.description = <<-EOF
    natto combines the Ruby programming language
    with MeCab, the part-of-speech and morphological
    analyzer for the Japanese language.
  EOF
  s.author = 'Brooke M. Fujita'
  s.email = 'buruzaemon@gmail.com'
  s.homepage = 'http://code.google.com/p/natto/'
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 1.8.7'
  s.require_path = 'lib'
  s.requirements << 'MeCab, 0.98 or greater'
  s.files = FileList['lib/**/*.rb', 'test/**/test_natto.rb', 'LICENSE']
  s.test_file  = 'test/test_natto.rb'
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar_gz = true
end

desc "Run unit tests"
task :test do 
  ruby %{ test/test_natto.rb }
end

task :default => [:test]
