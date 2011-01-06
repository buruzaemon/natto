# -*- coding: UTF-8 -*-
$:.unshift('lib')
require 'rubygems' if RUBY_VERSION.to_f < 1.9
require 'natto/version'

Gem::Specification.new do |s|
  s.name = 'natto'
  s.version = Natto::VERSION
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
  s.requirements << 'FFI, 0.6.3 or greater'
  s.files = [
    'lib/natto.rb', 
    'lib/natto/binding.rb', 
    'lib/natto/version.rb', 
    'test/test_natto.rb', 
    'LICENSE', 
    'README.md'
  ]
  s.extra_rdoc_files = [
    'LICENSE', 
    'README.md'
  ]
  s.rdoc_options << '--title' << 'natto #{Natto::VERSION} -- Ruby-Mecab binding'
  s.rdoc_options << '--main' << 'README'
  s.rdoc_options << '-c UTF-8'
  s.has_rdoc = "yard"
  s.test_file  = 'test/test_natto.rb'
end
