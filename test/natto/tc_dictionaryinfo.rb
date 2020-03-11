# coding: utf-8
require 'open3'
require 'rbconfig'

class TestDictionaryInfo < Minitest::Test
  def setup
    @testdic = File.join(Dir.pwd, 'test', 'natto', 'test.dic')
    begin
      File.delete(@testdic) if File.exist?(@testdic)
    rescue SystemCallError
      $stderr.puts "[INFO] setup: could not delete test.dic, you might want to remove manually."
    end

    @host_os = RbConfig::CONFIG['host_os']

    testcsv = File.join(Dir.pwd, 'test', 'natto', 'test_userdic.csv')
    
    if @host_os =~ /mswin|mingw/i
      require 'win32/registry'
      base = nil
      Win32::Registry::HKEY_CURRENT_USER.open('Software\MeCab') do |r|
        base = r['mecabrc'] 
      end
      raise 'TestDictionaryInfo.setup: cannot locate MeCab install in registry' if base.nil?

      ledir = File.join(base.split('etc').first, 'bin')
      ledir = File.realpath(ledir)
    else
      ledir = `mecab-config --libexecdir`.strip
    end
    
    mdi   = "\"#{File.join(ledir, 'mecab-dict-index')}\""
    
    out = `mecab -P`.lines.to_a.keep_if {|e| e=~/^dicdir/}
    dicdir = out.first[8...-1].strip
    dicdir = "\"#{File.realpath(dicdir)}\""

    out = `mecab -D`.lines.to_a.keep_if {|e| e=~/^charset/}
    enc = out.first[9...-1].strip

    cmd = "#{mdi} --dicdir #{dicdir} --userdic #{@testdic} --dictionary-charset #{enc} --charset #{enc} #{testcsv}"
    Open3.popen3(cmd) do |stdin,stdout,stderr|
      stdout.read.split("\n").each {|l| $stdout.puts l }
    end
    
    m = Natto::MeCab.new("-u #{@testdic}")
    refute_nil(m, "FAIL! No good usr dics")
    @dicts = m.dicts

    out = `mecab -u #{@testdic} -D`.lines.to_a

    @sysdic_filename = out[0].split("\t")[1].strip
    @sysdic_filepath = File.absolute_path(@sysdic_filename)
    @sysdic_charset  = out[2].split("\t")[1].strip
    @sysdic_type     = out[3].split("\t")[1].strip.to_i

    @usrdic_filename = out[8].split("\t")[1].strip
    @usrdic_filepath = File.absolute_path(@usrdic_filename)
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
    
    begin
      File.delete(@testdic) if File.exist?(@testdic)
    rescue
      $stderr.puts "[INFO] teardown: could not delete test.dic, please remove manually."
    end
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
    assert(@dicts.first.to_s.include?("@filepath=\"#{@sysdic_filepath}\", charset=#{@sysdic_charset}, type=#{@sysdic_type}")) 
    assert(@dicts.last.to_s.include?("@filepath=\"#{@usrdic_filepath}\", charset=#{@usrdic_charset}, type=#{@usrdic_type}"))
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

# Copyright (c) 2020, Brooke M. Fujita.
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
