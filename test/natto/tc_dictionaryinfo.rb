# coding: utf-8

# TestDictionaryInfo encapsulates tests for the basic
# behavior of Natto::DictionaryInfo
class TestDictionaryInfo < Test::Unit::TestCase
  def setup
    @m = Natto::MeCab.new
  end

  def teardown
    @m = nil
  end

  # Tests the dictionaries accessor method of Natto::MeCab.
  # Assumes that:
  # a) system dictionary is /usr/local/lib/mecab/dic/ipadic/sys.dic
  # b) system dictionary encoding is utf-8
  # c) only dealing w/ case of 1 dictionary being used
  def test_dictionaries_accessor
    dicts = @m.dicts
    assert dicts.empty? == false
    sysdic = dicts.first
    assert_equal('/usr/local/lib/mecab/dic/ipadic/sys.dic', sysdic[:filename])
    assert_equal('utf8', sysdic[:charset])
    assert_equal(0x0, sysdic[:next].address)
  end

  # Tests the to_s method.
  def test_to_s
    assert_equal('/usr/local/lib/mecab/dic/ipadic/sys.dic', @m.dicts.first.to_s)
  end

  # Tests the accessors of Natto::DictionaryInfo.
  # Note: Object#type is deprecated in 1.9.n, but comes with a warning
  #       in 1.8.n
  def test_dictionary_info_member_accessors
    sysdic = @m.dicts.first
    members = %w( filename charset type size lsize rsize version next )
    members.each do |nomme|
      assert_not_nil(sysdic.send nomme.to_sym ) 
    end
    
    # NoMethodError will be raised for anything else!
    assert_raise NoMethodError do
      sysdic.send :unknown_attr
    end
  end
end
