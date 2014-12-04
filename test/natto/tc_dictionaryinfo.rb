# coding: utf-8
require 'open3'
require 'rbconfig'

class TestDictionaryInfo < MiniTest::Unit::TestCase
  def setup
    @host_os = RbConfig::CONFIG['host_os']

    usrdic, m = nil,nil

    begin

      testcsv = File.join(Dir.pwd, 'test', 'natto', 'test_userdic.csv')

      @testdic = File.join(Dir.pwd, 'test', 'natto', 'test.dic')
      
      if @host_os =~ /mswin|mingw/i
        require 'win32/registry'
        base = nil
        Win32::Registry::HKEY_CURRENT_USER.open('Software\MeCab') do |r|
          base = r['mecabrc'] 
        end
        raise 'TestDictionaryInfo.setup: cannot locate MeCab install in registry' if base.nil?

        ledir = base.split('etc')+'bin' 
      else
        ledir = `mecab-config --libexecdir`.strip
      end
    
      mdi   = File.join(ledir, 'mecab-dict-index')
      
      out = `mecab -P`.lines.to_a.keep_if {|e| e=~/^dicdir/}
      dicdir = out.first[8...-1].strip

      out = `mecab -D`.lines.to_a.keep_if {|e| e=~/^charset/}
      enc = out.first[9...-1].strip

      File.delete(@testdic) if File.exist?(@testdic)

      cmd = "#{mdi} --dicdir #{dicdir} --userdic #{@testdic} --dictionary-charset #{enc} --charset #{enc} #{testcsv}"

      Open3.popen3(cmd) do |stdin,stdout,stderr|
        stdout.read.split("\n").each {|l| $stdout.puts l }
        #puts
        #p stderr.read
      end
      
      m = Natto::MeCab.new("-u #{@testdic}")
    rescue
      #retry unless encs.empty?
    end
    refute_nil(m, "FAIL! No good usr dics")
    @dicts = m.dicts

    out = `mecab -u #{@testdic} -D`.lines.to_a

    @sysdic_filename = out[0].split("\t")[1].strip
    @sysdic_charset  = out[2].split("\t")[1].strip
    @sysdic_type     = out[3].split("\t")[1].strip.to_i

    @usrdic_filename = out[8].split("\t")[1].strip
    @usrdic_charset  = out[10].split("\t")[1].strip
    @usrdic_type     = out[11].split("\t")[1].strip.to_i
  end

  def teardown
    @dicts              = nil
    @sysdic_filename    = nil
    @sysdic_charset     = nil
    @sysdic_type        = nil
    @usrdic_filename    = nil
    @usrdic_charset     = nil
    @usrdic_type        = nil
    
    File.delete(@testdic) if File.exist?(@testdic)
  end

  # Tests the dictionaries accessor method of Natto::MeCab.
  def test_dictionaries_accessor
    assert @dicts.empty? == false
    sysdic = @dicts.first
    assert_equal(@sysdic_type, sysdic[:type])
    assert_equal(@sysdic_filename, sysdic[:filename])
    assert_equal(@sysdic_charset, sysdic[:charset])
    refute_equal(0x0, sysdic[:next].address)

    usrdic = @dicts.last
    assert_equal(@usrdic_type, usrdic[:type])
    assert_equal(@usrdic_filename, usrdic[:filename])
    assert_equal(@usrdic_charset, usrdic[:charset])
    assert_equal(0x0, usrdic[:next].address)
  end

  def test_to_s
    assert(@dicts.first.to_s.include?("type=\"#{@sysdic_type}\", filename=\"#{@sysdic_filename}\", charset=\"#{@sysdic_charset}\""))
    assert(@dicts.last.to_s.include?("type=\"#{@usrdic_type}\", filename=\"#{@usrdic_filename}\", charset=\"#{@usrdic_charset}\""))
  end

  # Note: Object#type is deprecated in 1.9.n, but comes with a warning
  #       in 1.8.n
  def test_dictionary_info_member_accessors
    sysdic = @dicts.first
    members = [
      :filename,
      :charset,
      :size,
      :lsize,
      :rsize,
      :version,
      :next 
    ]
    members << :type if RUBY_VERSION.to_f < 1.9
    members.each do |nomme|
      refute_nil(sysdic.send nomme) 
    end
    
    assert_raises NoMethodError do
      sysdic.send :unknown_attr
    end
  end

  def test_is
    assert @dicts[0].is_sysdic? == true      
    assert @dicts[0].is_usrdic? == false      
    assert @dicts[0].is_unkdic? == false      

    assert @dicts[1].is_sysdic? == false      
    assert @dicts[1].is_usrdic? == true      
    assert @dicts[1].is_unkdic? == false      
  end
end
