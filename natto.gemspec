# coding: utf-8
$:.unshift('lib')
require 'natto/version'

Gem::Specification.new do |s|
  s.name = 'natto'
  s.version = Natto::VERSION
  s.add_dependency('ffi', '>= 1.9.0')
  s.license = 'BSD'
  s.summary = 'natto combines the Ruby programming language with MeCab, the part-of-speech and morphological analyzer for the Japanese language.'
  s.description = <<END_DESC
natto bridges Ruby and MeCab via FFI (foreign function interface). No compiling is necessary, and natto will run on CRuby (mri/yarv) and JRuby (jvm) equally well, on any OS. natto provides the most natural, Ruby-esque API for MeCab.
END_DESC
  s.author = 'Brooke M. Fujita'
  s.email = 'buruzaemon@gmail.com'
  s.homepage = 'https://bitbucket.org/buruzaemon/natto'
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 1.9'
  s.require_path = 'lib'
  s.requirements << 'MeCab, 0.996 or greater'
  s.requirements << 'FFI, 1.9.0 or greater'
  s.files = [
    'lib/natto.rb', 
    'lib/natto/binding.rb', 
    'lib/natto/natto.rb', 
    'lib/natto/option_parse.rb', 
    'lib/natto/struct.rb', 
    'lib/natto/version.rb', 
    'README.md',
    'LICENSE', 
    'CHANGELOG',
    '.yardopts'
  ]
end
