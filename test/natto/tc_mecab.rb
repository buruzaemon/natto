# coding: utf-8
require 'rbconfig'

class TestMeCab < Minitest::Test
    
  def setup
    @ver  = `mecab -v`.strip.split.last
    @host_os = RbConfig::CONFIG['host_os']
    @arch    = RbConfig::CONFIG['arch']
    
    if @host_os =~ /mswin|mingw/i
      @test_cmd = 'type "test\\natto\\test_sjis"'
      @br       = '\\n'
   
      lines = []
      File.open('test/natto/test_utf8_partial', 'rb:utf-8:cp932') do |f|
        lines = f.readlines
      end

      lines2 = []
      File.open('test/natto/test_utf8_boundary', 'rb:utf-8:cp932') do |f|
        lines2 = f.readlines
      end

      lines3 =  []
      File.open('test/natto/test_utf8_feature', 'rb:utf-8:cp932') do |f|
        lines3 = f.readlines
      end
    else
      @test_cmd = 'cat "test/natto/test_utf8"'
      @br       = '\n'
      
      lines = []
      File.open('test/natto/test_utf8_partial', 'rb:utf-8') do |f|
        lines = f.readlines
      end
      
      lines2 = []
      File.open('test/natto/test_utf8_boundary', 'rb:utf-8') do |f|
        lines2 = f.readlines
      end

      lines3 =  []
      File.open('test/natto/test_utf8_feature', 'rb:utf-8') do |f|
        lines3 = f.readlines
      end
    end
    @test_str   = `#{@test_cmd}`.strip

    @test_partial = lines[0..2].join.strip
    @test_partial_res = lines[4].strip.split(',')
    @test_partial_res2 = lines[5].strip.split('|')

    @test_bc = lines2[0].strip
    @test_bc_pattern = lines2[1].strip
    @test_bc_res = lines2[2].strip.split(',')

    @test_bc2 = lines2[4].strip
    @test_bc_pattern2 = lines2[5].strip
    @test_bc_res2 = lines2[6].strip.split(',')

    @test_fc = lines3[0].strip
    toks  = lines3[1].strip.split(',')
    @test_fc_hash = { toks[0] => toks[1] }
    @test_fc_res = lines3[2].strip.split('|')
  end

  def teardown
    @ver      = nil
    @host_os  = nil
    @arch     = nil
    @test_cmd = nil
    @br       = nil
    @test_str = nil

    @test_partial = nil
    @test_partial_res = nil

    @test_bc = nil
    @test_bc_pattern = nil
    @test_bc_res = nil

    @test_bc2 = nil
    @test_bc_pattern2 = nil
    @test_bc_res2 = nil

    @test_fc = nil
    @test_fc_hash = nil
    @test_fc_res = nil
  end
 
  def test_parse_mecab_options
    [ '-r /some/file',
      '-r/some/file',
      '--rcfile=/some/file',
      '--rcfile /some/file',
      {rcfile: "/some/file"} ].each do |opts|
      assert_equal({rcfile: '/some/file'}, Natto::MeCab.parse_mecab_options(opts))
    end

    [ '-d /some/other/file',
      '-d/some/other/file',
      '--dicdir=/some/other/file',
      '--dicdir /some/other/file',
      {dicdir: "/some/other/file"} ].each do |opts|
      assert_equal({dicdir: '/some/other/file'}, Natto::MeCab.parse_mecab_options(opts))
    end
   
    [ '-u /yet/another/file',
      '-u/yet/another/file',
      '--userdic=/yet/another/file',
      '--userdic /yet/another/file',
      {userdic: "/yet/another/file"} ].each do |opts|
      assert_equal({userdic: '/yet/another/file'}, Natto::MeCab.parse_mecab_options(opts))
    end
   
    [ '-l 42',
      '-l42',
      '--lattice-level=42',
      '--lattice-level 42',
      {lattice_level: 42}
    ].each do |opts|
      assert_equal({lattice_level: 42}, Natto::MeCab.parse_mecab_options(opts))
    end
   
    [ '-a',
      '--all-morphs',
      {all_morphs: true} ].each do |opts|
      assert_equal({all_morphs: true}, Natto::MeCab.parse_mecab_options(opts))
    end
   
    [ '-O natto',
      '-Onatto',
      '--output-format-type=natto',
      '--output-format-type natto',
      {output_format_type: "natto"} ].each do |opts|
      assert_equal({output_format_type: 'natto'}, Natto::MeCab.parse_mecab_options(opts))
    end
   
    [ '-N 42',
      '-N42',
      '--nbest=42',
      '--nbest 42',
      {nbest: 42}
    ].each do |opts|
      assert_equal({nbest: 42}, Natto::MeCab.parse_mecab_options(opts))
    end
    [ '--nbest=-1', '--nbest=0', '--nbest=513' ].each do |bad|
      assert_raises Natto::MeCabError do
        Natto::MeCab.parse_mecab_options(bad)
      end
    end

    [ '-p',
      '--partial',
      {partial: true}
    ].each do |opts|
      assert_equal({partial: true}, Natto::MeCab.parse_mecab_options(opts))
    end
   
    [ '-m',
      '--marginal',
      {marginal: true}
    ].each do |opts|
      assert_equal({marginal: true}, Natto::MeCab.parse_mecab_options(opts))
    end
   
    [ '-M 42',
      '-M42',
      '--max-grouping-size=42',
      '--max-grouping-size 42',
      {max_grouping_size: 42}
    ].each do |opts|
      assert_equal({max_grouping_size: 42}, Natto::MeCab.parse_mecab_options(opts))
    end
   
    [ '-F %m\t%f[7]\n',
      '-F%m\t%f[7]\n',
      '--node-format=%m\t%f[7]\n',
      '--node-format %m\t%f[7]\n',
      {node_format: '%m\t%f[7]\n'} ].each do |opts|
      assert_equal({node_format: '%m\t%f[7]\n'}, Natto::MeCab.parse_mecab_options(opts))
    end

    [ '-U %m\t%f[7]\n',
      '-U%m\t%f[7]\n',
      '--unk-format=%m\t%f[7]\n',
      '--unk-format %m\t%f[7]\n',
      {unk_format: '%m\t%f[7]\n'} ].each do |opts|
      assert_equal({unk_format: '%m\t%f[7]\n'}, Natto::MeCab.parse_mecab_options(opts))
    end
    
    [ '-B %m\t%f[7]\n',
      '-B%m\t%f[7]\n',
      '--bos-format=%m\t%f[7]\n',
      '--bos-format %m\t%f[7]\n',
      {bos_format: '%m\t%f[7]\n'} ].each do |opts|
      assert_equal({bos_format: '%m\t%f[7]\n'}, Natto::MeCab.parse_mecab_options(opts))
    end
    
    [ '-E %m\t%f[7]\n',
      '-E%m\t%f[7]\n',
      '--eos-format=%m\t%f[7]\n',
      '--eos-format %m\t%f[7]\n',
      {eos_format: '%m\t%f[7]\n'} ].each do |opts|
      assert_equal({eos_format: '%m\t%f[7]\n'}, Natto::MeCab.parse_mecab_options(opts))
    end
    
    [ '-S %m\t%f[7]\n',
      '-S%m\t%f[7]\n',
      '--eon-format=%m\t%f[7]\n',
      '--eon-format %m\t%f[7]\n',
      {eon_format: '%m\t%f[7]\n'} ].each do |opts|
      assert_equal({eon_format: '%m\t%f[7]\n'}, Natto::MeCab.parse_mecab_options(opts))
    end
    
    [ '-x %m\t%f[7]\n',
      '-x%m\t%f[7]\n',
      '--unk-feature=%m\t%f[7]\n',
      '--unk-feature %m\t%f[7]\n',
      {unk_feature: '%m\t%f[7]\n'} ].each do |opts|
      assert_equal({unk_feature: '%m\t%f[7]\n'}, Natto::MeCab.parse_mecab_options(opts))
    end
    
    [ '-b 102400',
      '-b102400',
      '--input-buffer-size=102400',
      '--input-buffer-size 102400',
      {input_buffer_size: 102400} ].each do |opts|
      assert_equal({input_buffer_size: 102400}, Natto::MeCab.parse_mecab_options(opts))
    end
    
    [ '-C',
      '--allocate-sentence',
      {allocate_sentence: true} ].each do |opts|
      assert_equal({allocate_sentence: true}, Natto::MeCab.parse_mecab_options(opts))
    end
    
    [ '-t 0.42',
      '-t0.42',
      '--theta=0.42',
      '--theta 0.42',
      {theta: 0.42} ].each do |opts|
      assert_equal({theta: 0.42}, Natto::MeCab.parse_mecab_options(opts))
    end
    
    [ '-c 42',
      '-c42',
      '--cost-factor=42',
      '--cost-factor 42',
      {cost_factor: 42} ].each do |opts|
      assert_equal({cost_factor: 42}, Natto::MeCab.parse_mecab_options(opts))
    end

    assert_equal({}, Natto::MeCab.parse_mecab_options)
    assert_equal({}, Natto::MeCab.parse_mecab_options(unknown: "ignore"))
  end

  def test_build_options_str
    assert_equal('--rcfile=/some/file', Natto::MeCab.build_options_str(rcfile: "/some/file"))
    assert_equal('--dicdir=/some/other/file', Natto::MeCab.build_options_str(dicdir: "/some/other/file"))
    assert_equal('--userdic=/yet/another/file', Natto::MeCab.build_options_str(userdic: "/yet/another/file"))
    assert_equal('--lattice-level=42', Natto::MeCab.build_options_str(lattice_level: 42))
    assert_equal('--all-morphs', Natto::MeCab.build_options_str(all_morphs: true))
    assert_equal('--output-format-type=natto', Natto::MeCab.build_options_str(output_format_type: "natto"))
    assert_equal('--node-format=%m\t%f[7]\n', Natto::MeCab.build_options_str(node_format: '%m\t%f[7]\n'))
    assert_equal('--unk-format=%m\t%f[7]\n', Natto::MeCab.build_options_str(unk_format: '%m\t%f[7]\n'))
    assert_equal('--bos-format=%m\t%f[7]\n', Natto::MeCab.build_options_str(bos_format: '%m\t%f[7]\n'))
    assert_equal('--eos-format=%m\t%f[7]\n', Natto::MeCab.build_options_str(eos_format: '%m\t%f[7]\n'))
    assert_equal('--eon-format=%m\t%f[7]\n', Natto::MeCab.build_options_str(eon_format: '%m\t%f[7]\n'))
    assert_equal('--unk-feature=%m\t%f[7]\n', Natto::MeCab.build_options_str(unk_feature: '%m\t%f[7]\n'))
    assert_equal('--input-buffer-size=102400',Natto::MeCab.build_options_str(input_buffer_size: 102400))
    assert_equal('--allocate-sentence', Natto::MeCab.build_options_str(allocate_sentence: true))
    assert_equal('--nbest=42', Natto::MeCab.build_options_str(nbest: 42))
    assert_equal('--theta=0.42', Natto::MeCab.build_options_str(theta: 0.42))
    assert_equal('--cost-factor=42', Natto::MeCab.build_options_str(cost_factor: 42))
  end

  def test_lattice_level_warning
    [{lattice_level: 999}, '-l 999', '--lattice-level=999' ].each do |opt|
      out, err = capture_io do
        Natto::MeCab.new opt
      end
      assert_equal ":lattice-level is DEPRECATED, please use :marginal or :nbest\n", err
    end
  end

  def test_initialize_with_errors
    assert_raises Natto::MeCabError do
      Natto::MeCab.new(output_format_type: 'not_defined_anywhere')
    end
    
    assert_raises Natto::MeCabError do
      Natto::MeCab.new(rcfile: '/rcfile/does/not/exist')
    end

    assert_raises Natto::MeCabError do
      Natto::MeCab.new(dicdir: '/dicdir/does/not/exist')
    end

    assert_raises Natto::MeCabError do
      Natto::MeCab.new(userdic: '/userdic/does/not/exist')
    end
  end

  def test_version_accessor
    nm = Natto::MeCab.new
    assert_equal(@ver, nm.version)
  end

  def test_argument_error
    nm = Natto::MeCab.new
    nm_p = Natto::MeCab.new('-p')
    [ :parse, :enum_parse ].each do |m|
      assert_raises ArgumentError do
        nm.send(m, nil) 
      end

      assert_raises ArgumentError do
        nm.send(m, 'foobar', boundary_constraints: [])
      end
      
      assert_raises ArgumentError do
        nm.send(m, 'foobar', feature_constraints: [])
      end
      
      assert_raises ArgumentError do
        nm_p.send(m, 'foobar') 
      end
    end
  end

  # ----------- tostr ----------------------------
  
  def test_parse_tostr_default
    expected = `#{@test_cmd} | mecab`.lines.to_a
    expected.delete_if {|e| e =~ /^(EOS|BOS|\t)/ }
    expected.map!{|e| e.force_encoding(Encoding.default_external)} if @arch =~ /java/i && RUBY_VERSION.to_f >= 1.9

    nm = Natto::MeCab.new
    actual = nm.parse(@test_str).lines.to_a
    actual.delete_if {|e| e =~ /^(EOS|BOS|\t)/ }

    assert_equal(expected, actual)
  end

  def test_parse_tostr_wakati
    # -Owakati only really has affect when parsing to string
    opts = '-Owakati'
    expected = `#{@test_cmd} | mecab #{opts}`.lines.to_a
    expected.delete_if {|e| e =~ /^(EOS|BOS|\t)/ }
    expected.map!{|e| e.force_encoding(Encoding.default_external)} if @arch =~ /java/i && RUBY_VERSION.to_f >= 1.9

    nm = Natto::MeCab.new(opts)
    actual = nm.parse(@test_str).lines.to_a
    actual.delete_if {|e| e =~ /^(EOS|BOS|\t)/ }

    assert_equal(expected, actual)
  end

  def test_parse_tostr_yomi
    opts = '-Oyomi'
    expected = `#{@test_cmd} | mecab #{opts}`.lines.to_a
    expected.delete_if {|e| e =~ /^(EOS|BOS|\t)/ }
    expected.map!{|e| e.force_encoding(Encoding.default_external)} if @arch =~ /java/i && RUBY_VERSION.to_f >= 1.9

    nm = Natto::MeCab.new(opts)
    actual = nm.parse(@test_str).lines.to_a
    actual.delete_if {|e| e =~ /^(EOS|BOS|\t)/ }

    assert_equal(expected, actual)
  end

  def test_parse_tostr_output_formatting
    opts = '%m\t%s' 
    expected = `#{@test_cmd} | mecab -F"#{opts}"`

    nm = Natto::MeCab.new("-F#{opts}")
    actual = nm.parse(@test_str)

    assert_equal(expected, actual)
  end

  def test_parse_nbest_tostr
    opts = '-N2'
    expected = `#{@test_cmd} | mecab #{opts}`.lines.to_a
    expected.delete_if {|e| e =~ /^(EOS|\t)/ }
    expected.map!{|e| e.force_encoding(Encoding.default_external)} if @arch =~ /java/i && RUBY_VERSION.to_f >= 1.9

    nm = Natto::MeCab.new(opts)
    actual = nm.parse(@test_str).lines.to_a
    actual.delete_if {|e| e =~ /^(EOS|\t)/ }
    
    assert_equal(expected, actual)
  end

  def test_parse_nbest_tostr_outputformatting
    opts = '%pl\t%f[7]...'
    expected = `#{@test_cmd} | mecab -N2 -F"#{opts}"`.lines.to_a
    expected.delete_if {|e| e =~ /^(EOS|\t)/ }
    expected.map!{|e| e.force_encoding(Encoding.default_external)} if @arch =~ /java/i && RUBY_VERSION.to_f >= 1.9

    nm = Natto::MeCab.new("-N2 -F#{opts}")
    actual = nm.parse(@test_str).lines.to_a
    actual.delete_if {|e| e =~ /^(EOS|\t)/ }
    
    assert_equal(expected, actual)
  end
  
  def test_parse_tostr_all_morphs
    opts = '-a'
    expected = `#{@test_cmd} | mecab #{opts}`.lines.to_a
    expected.delete_if {|e| e =~ /^(EOS|BOS)/ }
    expected.map!{|e| e.force_encoding(Encoding.default_external)} if @arch =~ /java/i && RUBY_VERSION.to_f >= 1.9
  
    nm = Natto::MeCab.new(opts)
    actual   = nm.parse(@test_str).lines.to_a
    actual.delete_if {|e| e =~ /^(EOS|BOS|\t)/ }
    
    assert_equal(expected, actual)
  end

  def test_parse_tostr_theta
    opts = '-t 0.666'
    expected = `#{@test_cmd} | mecab #{opts}`.lines.to_a
    expected.delete_if {|e| e =~ /^(EOS|BOS|\t)/ }
    expected.map!{|e| e.force_encoding(Encoding.default_external)} if @arch =~ /java/i && RUBY_VERSION.to_f >= 1.9

    nm = Natto::MeCab.new(opts)
    actual = nm.parse(@test_str).lines.to_a
    actual.delete_if {|e| e =~ /^(EOS|BOS|\t)/ }

    assert_equal(expected, actual)
  end

  def test_parse_tostr_marginal
    opts = '-t 0.666'
    expected = `#{@test_cmd} | mecab #{opts}`.lines.to_a
    expected.delete_if {|e| e =~ /^(EOS|BOS|\t)/ }
    expected.map!{|e| e.force_encoding(Encoding.default_external)} if @arch =~ /java/i && RUBY_VERSION.to_f >= 1.9

    nm = Natto::MeCab.new(opts)
    actual = nm.parse(@test_str).lines.to_a
    actual.delete_if {|e| e =~ /^(EOS|BOS|\t)/ }

    assert_equal(expected, actual)
  end

  def test_parse_tostr_partial
    nm = Natto::MeCab.new('-p')    

    actual = nm.parse("#{@test_partial}\n").lines.to_a
    actual.each_with_index do |l,i|
      assert_match(@test_partial_res[i], l)
    end
  end

  def test_parse_tostr_boundary_constraints
    # simple string pattern
    nm = Natto::MeCab.new
    actual = nm.parse(@test_bc, boundary_constraints: Regexp.new(@test_bc_pattern)).lines.to_a
    actual.each_with_index do |l,i|
      assert_match(@test_bc_res[i], l)
    end

    # complex Unicode character pattern
    actual = nm.parse(@test_bc2, boundary_constraints: Regexp.new(@test_bc_pattern2)).lines.to_a
    actual.each_with_index do |l,i|
      assert_match(@test_bc_res2[i], l)
    end
  end

  #def test_parse_tostr_feature_constraints
  #  nm = Natto::MeCab.new('-F%m,%f[0],%s')

  #  actual = nm.parse(@test_fc, feature_constraints: @test_fc_hash).lines.to_a
  #  actual.each_with_index do |l,i|
  #    assert_match(@test_fc_res[i], l)
  #  end
  #end

  # ----------- tonodes --------------------------
  
  def test_parse_tonodes_default
    expected = `#{@test_cmd} | mecab`.lines.to_a
    expected.delete_if {|e| e =~ /^(EOS|BOS|\t)/ }
    expected.map!{|e| e.force_encoding(Encoding.default_external)} if @arch =~ /java/i && RUBY_VERSION.to_f >= 1.9

    nm = Natto::MeCab.new
    actual = []
    nm.parse(@test_str) do |n|
      actual << "#{n.surface}\t#{n.feature}\n" if n.is_nor?
    end

    assert_equal(expected, actual)
  end

  def test_parse_tonodes_yomi
    opts = '-Oyomi'
    expected = `#{@test_cmd} | mecab #{opts}`.lines.to_a
    expected.delete_if {|e| e =~ /^(EOS|BOS|\t)/ }
    expected.map!{|e| e.force_encoding(Encoding.default_external)} if @arch =~ /java/i && RUBY_VERSION.to_f >= 1.9
    expected = expected.join.strip

    nm = Natto::MeCab.new(opts)
    actual = []
    nm.parse(@test_str) {|n| actual << n.feature if n.is_nor? }    
  
    assert_equal(expected, actual.join)
  end

  def test_parse_tonodes_output_formatting
    opts = '%pl\t%f[7]...'
    expected = `#{@test_cmd} | mecab -F"#{opts}"`.split("EOS\n").join.split('...')
    expected.map!{|e| e.force_encoding(Encoding.default_external)} if @arch =~ /java/i && RUBY_VERSION.to_f >= 1.9

    nm = Natto::MeCab.new("-F#{opts}")
    actual = []
    nm.parse(@test_str) {|n| actual << n if n.is_nor?}    
   
    expected.each_with_index do |f,i|
      sl, y = f.split("\t").map{|e| e.strip}
      asl, ay = actual[i].feature.split('...').first.split("\t").map{|e| e.strip}
      assert_equal(sl, asl)
      assert_equal(y, ay)
    end
  end

  def test_parse_nbest_tonodes
    opts = '-N2'
    expected = `#{@test_cmd} | mecab #{opts}`.lines.to_a
    expected.delete_if {|e| e =~ /^(EOS|\t)/ }
    expected.map!{|e| e.force_encoding(Encoding.default_external)} if @arch =~ /java/i && RUBY_VERSION.to_f >= 1.9

    nm = Natto::MeCab.new(opts)
    actual = []
    nm.parse(@test_str) {|n| actual << n if n.is_nor? }    
  
    expected.each_with_index do |f,i|
      a = actual[i]
      assert_equal(f.strip, "#{a.surface}\t#{a.feature}")
    end
  end

  def test_parse_nbest_tonodes_output_formatting
    opts = '%pl\t%f[7]...'
    expected = `#{@test_cmd} | mecab -N2 -F"#{opts}"`.split("EOS\n").join.split('...')
    expected.map!{|e| e.force_encoding(Encoding.default_external)} if @arch =~ /java/i && RUBY_VERSION.to_f >= 1.9

    nm = Natto::MeCab.new("-N2 -F#{opts}")
    actual = []
    nm.parse(@test_str) {|n| actual << n if n.is_nor?}    
   
    expected.each_with_index do |f,i|
      sl, y = f.split("\t").map{|e| e.strip}
      asl, ay = actual[i].feature.split('...').first.split("\t").map{|e| e.strip}
      assert_equal(sl, asl)
      assert_equal(y, ay)
    end
  end

  def test_parse_tonodes_all_morphs
    opts = '-a'
    expected = `#{@test_cmd} | mecab #{opts}`.lines.to_a
    expected.delete_if {|e| e =~ /^(EOS|BOS)/ }
    expected.map!{|e| e.force_encoding(Encoding.default_external)} if @arch =~ /java/i && RUBY_VERSION.to_f >= 1.9
  
    nm = Natto::MeCab.new(opts)
    actual = []
    nm.parse(@test_str) {|n| actual << n if !n.is_eos?}
    expected.each_with_index do |e,i|
      a = actual[i]
      assert_equal(e.strip, "#{a.surface}\t#{a.feature}")
    end
  end

  def test_parse_tonodes_theta
    opts = '-t 0.666'
    expected = `#{@test_cmd} | mecab #{opts}`.lines.to_a
    expected.delete_if {|e| e =~ /^(EOS|BOS|\t)/ }
    expected.map!{|e| e.force_encoding(Encoding.default_external)} if @arch =~ /java/i && RUBY_VERSION.to_f >= 1.9

    nm = Natto::MeCab.new(opts)
    actual = []
    nm.parse(@test_str) do |n|
      actual << "#{n.surface}\t#{n.feature}\n" if n.is_nor?
    end

    assert_equal(expected, actual)
  end

  def test_parse_tonodes_marginal
    opts = '-t 0.666'
    nm = Natto::MeCab.new(opts)
    nm.parse(@test_str) do |n|
      if !(n.is_eos? or n.is_bos?)
        assert(n.prob == 0.0)
        assert(n.alpha == 0.0)
        assert(n.beta == 0.0)
      end
    end

    opts2 = '-m -t 0.001'
    nm2 = Natto::MeCab.new(opts2)
    nm2.parse(@test_str) do |n|
      if !(n.is_eos? or n.is_bos?)
        assert(n.prob != 0.0)
        assert(n.alpha != 0.0)
        assert(n.beta != 0.0)
      end
    end
  end

  def test_parse_tonodes_partial_output_formatting
    nm = Natto::MeCab.new('-p -F%m,%F,[0]')

    actual = []
    nm.parse("#{@test_partial}\n") {|n| actual << n.feature if !(n.is_bos? || n.is_eos?)}    
    actual.each_with_index do |l,i|
      assert_match(@test_partial_res2[i], l)
    end
  end

  def test_parse_tonodes_boundary_constraints
    # simple string pattern
    nm = Natto::MeCab.new
    actual = []
    nm.parse(@test_bc, boundary_constraints: Regexp.new(@test_bc_pattern)) {|n| actual << n if !(n.is_bos? || n.is_eos?)}    
    actual.each_with_index do |l,i|
      assert_match(@test_bc_res[i], l.surface)
    end

    # complex Unicode character pattern
    actual = []
    nm.parse(@test_bc2, boundary_constraints: Regexp.new(@test_bc_pattern2)) {|n| actual << n if !(n.is_bos? || n.is_eos?)}    
    actual.each_with_index do |l,i|
      assert_match(@test_bc_res2[i], l.surface)
    end
  end

  #def test_parse_tonodes_feature_constraints
  #  nm = Natto::MeCab.new('-F%m,%f[0],%s')

  #  actual = []
  #  nm.enum_parse(@test_fc, feature_constraints: @test_fc_hash).each {|n| actual << n}
  #  actual.each_with_index do |n,i|
  #    assert_match(@test_fc_res[i], n.feature)
  #  end
  #end

  # ----------- enum_parse -----------------------
  
  def test_enum_parse_default
    expected = `#{@test_cmd} | mecab`.lines.to_a
    expected.delete_if {|e| e =~ /^(EOS|BOS|\t)/ }
    expected.map!{|e| e.force_encoding(Encoding.default_external)} if @arch =~ /java/i && RUBY_VERSION.to_f >= 1.9

    nm = Natto::MeCab.new
    enum = nm.enum_parse(@test_str)

    assert_equal(expected[0].split.first, enum.next.surface)
    assert_equal(expected[1].split.first, enum.next.surface)
    assert_equal(expected[2].split.first, enum.next.surface)
    assert_equal(expected[3].split.first, enum.next.surface)
    assert_equal(expected[4].split.first, enum.next.surface)
    assert_equal(expected[5].split.first, enum.next.surface)
    assert_equal(expected[6].split.first, enum.next.surface)
  end
  
  def test_enum_parse_with_format
    opts = '%f[1]'
    expected = `#{@test_cmd} | mecab -F"#{opts}#{@br}"`.lines.to_a
    expected.delete_if {|e| e =~ /^(EOS|BOS|\t)/ }
    expected.map!{|e| e.force_encoding(Encoding.default_external)} if @arch =~ /java/i && RUBY_VERSION.to_f >= 1.9

    nm = Natto::MeCab.new("-F#{opts}")
    enum = nm.enum_parse(@test_str)

    assert_equal(expected[0].strip, enum.next.feature)
    assert_equal(expected[1].strip, enum.next.feature)
    assert_equal(expected[2].strip, enum.next.feature)
    assert_equal(expected[3].strip, enum.next.feature)
    assert_equal(expected[4].strip, enum.next.feature)
    assert_equal(expected[5].strip, enum.next.feature)
    assert_equal(expected[6].strip, enum.next.feature)
  end
end 

# Copyright (c) 2015, Brooke M. Fujita.
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
