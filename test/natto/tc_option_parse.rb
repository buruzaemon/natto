# coding: utf-8

class TestOptionParse < Minitest::Test
  def setup
    @klass = Class.new do
      include Natto::OptionParse
    end
  end

  def teardown
    @klass = nil
  end
  
  def test_functions_included
    [ :parse_mecab_options, :build_options_str ].each do |f|
      assert(@klass.respond_to? f)
    end
  end
  
  def test_parse_mecab_options
    [ '-r /some/file',
      '-r/some/file',
      '--rcfile=/some/file',
      '--rcfile /some/file',
      {rcfile: "/some/file"} ].each do |opts|
      assert_equal({rcfile: '/some/file'}, @klass.parse_mecab_options(opts))
    end

    [ '-d /some/other/file',
      '-d/some/other/file',
      '--dicdir=/some/other/file',
      '--dicdir /some/other/file',
      {dicdir: "/some/other/file"} ].each do |opts|
      assert_equal({dicdir: '/some/other/file'}, @klass.parse_mecab_options(opts))
    end
   
    [ '-u /yet/another/file',
      '-u/yet/another/file',
      '--userdic=/yet/another/file',
      '--userdic /yet/another/file',
      {userdic: "/yet/another/file"} ].each do |opts|
      assert_equal({userdic: '/yet/another/file'}, @klass.parse_mecab_options(opts))
    end
   
    [ '-l 42',
      '-l42',
      '--lattice-level=42',
      '--lattice-level 42',
      {lattice_level: 42}
    ].each do |opts|
      assert_equal({lattice_level: 42}, @klass.parse_mecab_options(opts))
    end
   
    [ '-a',
      '--all-morphs',
      {all_morphs: true} ].each do |opts|
      assert_equal({all_morphs: true}, @klass.parse_mecab_options(opts))
    end
   
    [ '-O natto',
      '-Onatto',
      '--output-format-type=natto',
      '--output-format-type natto',
      {output_format_type: "natto"} ].each do |opts|
      assert_equal({output_format_type: 'natto'}, @klass.parse_mecab_options(opts))
    end
   
    [ '-N 42',
      '-N42',
      '--nbest=42',
      '--nbest 42',
      {nbest: 42}
    ].each do |opts|
      assert_equal({nbest: 42}, @klass.parse_mecab_options(opts))
    end
    [ '--nbest=-1', '--nbest=0', '--nbest=513' ].each do |bad|
      assert_raises Natto::MeCabError do
        @klass.parse_mecab_options(bad)
      end
    end
   
    [ '-p',
      '--partial',
      {partial: true} ].each do |opts|
      assert_equal({partial: true}, @klass.parse_mecab_options(opts))
    end
   
    [ '-m',
      '--marginal',
      {marginal: true} ].each do |opts|
      assert_equal({marginal: true}, @klass.parse_mecab_options(opts))
    end
   
    [ '-M 42',
      '-M42',
      '--max-grouping-size=42',
      '--max-grouping-size 42',
      {max_grouping_size: 42}
    ].each do |opts|
      assert_equal({max_grouping_size: 42}, @klass.parse_mecab_options(opts))
    end
    
    [ '-F %m\t%f[7]\n',
      '-F%m\t%f[7]\n',
      '--node-format=%m\t%f[7]\n',
      '--node-format %m\t%f[7]\n',
      {node_format: '%m\t%f[7]\n'} ].each do |opts|
      assert_equal({node_format: '%m\t%f[7]\n'}, @klass.parse_mecab_options(opts))
    end

    [ '-U %m\t%f[7]\n',
      '-U%m\t%f[7]\n',
      '--unk-format=%m\t%f[7]\n',
      '--unk-format %m\t%f[7]\n',
      {unk_format: '%m\t%f[7]\n'} ].each do |opts|
      assert_equal({unk_format: '%m\t%f[7]\n'}, @klass.parse_mecab_options(opts))
    end
    
    [ '-B %m\t%f[7]\n',
      '-B%m\t%f[7]\n',
      '--bos-format=%m\t%f[7]\n',
      '--bos-format %m\t%f[7]\n',
      {bos_format: '%m\t%f[7]\n'} ].each do |opts|
      assert_equal({bos_format: '%m\t%f[7]\n'}, @klass.parse_mecab_options(opts))
    end
    
    [ '-E %m\t%f[7]\n',
      '-E%m\t%f[7]\n',
      '--eos-format=%m\t%f[7]\n',
      '--eos-format %m\t%f[7]\n',
      {eos_format: '%m\t%f[7]\n'} ].each do |opts|
      assert_equal({eos_format: '%m\t%f[7]\n'}, @klass.parse_mecab_options(opts))
    end
    
    [ '-S %m\t%f[7]\n',
      '-S%m\t%f[7]\n',
      '--eon-format=%m\t%f[7]\n',
      '--eon-format %m\t%f[7]\n',
      {eon_format: '%m\t%f[7]\n'} ].each do |opts|
      assert_equal({eon_format: '%m\t%f[7]\n'}, @klass.parse_mecab_options(opts))
    end
    
    [ '-x %m\t%f[7]\n',
      '-x%m\t%f[7]\n',
      '--unk-feature=%m\t%f[7]\n',
      '--unk-feature %m\t%f[7]\n',
      {unk_feature: '%m\t%f[7]\n'} ].each do |opts|
      assert_equal({unk_feature: '%m\t%f[7]\n'}, @klass.parse_mecab_options(opts))
    end
    
    [ '-b 102400',
      '-b102400',
      '--input-buffer-size=102400',
      '--input-buffer-size 102400',
      {input_buffer_size: 102400} ].each do |opts|
      assert_equal({input_buffer_size: 102400}, @klass.parse_mecab_options(opts))
    end
    
    [ '-C',
      '--allocate-sentence',
      {allocate_sentence: true} ].each do |opts|
      assert_equal({allocate_sentence: true}, @klass.parse_mecab_options(opts))
    end
    
    [ '-t 0.42',
      '-t0.42',
      '--theta=0.42',
      '--theta 0.42',
      {theta: 0.42} ].each do |opts|
      assert_equal({theta: 0.42}, @klass.parse_mecab_options(opts))
    end
    
    [ '-c 42',
      '-c42',
      '--cost-factor=42',
      '--cost-factor 42',
      {cost_factor: 42} ].each do |opts|
      assert_equal({cost_factor: 42}, @klass.parse_mecab_options(opts))
    end

    assert_equal({}, @klass.parse_mecab_options)
    assert_equal({}, @klass.parse_mecab_options(unknown: "ignore"))
  end

  def test_build_options_str
    assert_equal('--rcfile=/some/file', @klass.build_options_str(rcfile: "/some/file"))
    assert_equal('--dicdir=/some/other/file', @klass.build_options_str(dicdir: "/some/other/file"))
    assert_equal('--userdic=/yet/another/file', @klass.build_options_str(userdic: "/yet/another/file"))
    assert_equal('--lattice-level=42', @klass.build_options_str(lattice_level: 42))
    assert_equal('--output-format-type=natto', @klass.build_options_str(output_format_type: "natto"))
    assert_equal('--all-morphs', @klass.build_options_str(all_morphs: true))
    assert_equal('--nbest=42', @klass.build_options_str(nbest: 42))
    assert_equal('--partial', @klass.build_options_str(partial: true))
    assert_equal('--marginal', @klass.build_options_str(marginal: true))
    assert_equal('--node-format=%m\t%f[7]\n', @klass.build_options_str(node_format: '%m\t%f[7]\n'))
    assert_equal('--unk-format=%m\t%f[7]\n', @klass.build_options_str(unk_format: '%m\t%f[7]\n'))
    assert_equal('--bos-format=%m\t%f[7]\n', @klass.build_options_str(bos_format: '%m\t%f[7]\n'))
    assert_equal('--eos-format=%m\t%f[7]\n', @klass.build_options_str(eos_format: '%m\t%f[7]\n'))
    assert_equal('--eon-format=%m\t%f[7]\n', @klass.build_options_str(eon_format: '%m\t%f[7]\n'))
    assert_equal('--unk-feature=%m\t%f[7]\n', @klass.build_options_str(unk_feature: '%m\t%f[7]\n'))
    assert_equal('--input-buffer-size=102400',@klass.build_options_str(input_buffer_size: 102400))
    assert_equal('--allocate-sentence', @klass.build_options_str(allocate_sentence: true))
    assert_equal('--theta=0.42', @klass.build_options_str(theta: 0.42))
    assert_equal('--cost-factor=42', @klass.build_options_str(cost_factor: 42))
  end
end

# Copyright (c) 2019, Brooke M. Fujita.
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
#  * Redistributions of source code must retain the above
#    copyright notice, this list of conditions and the
#    following disclaimer.
# 
#  * Redistributions in binary form must reproduce the above
#    copyright notice, this list of conditions and the
#    following disclaimer in the documentation and/or other
#    materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
