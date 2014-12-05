# coding: utf-8

class TestNattoBinding < MiniTest::Unit::TestCase
  def setup
    @ver = `mecab -v`.strip.split.last
    @klass = Class.new do
      include Natto::Binding
    end
  end

  def teardown
    @ver, @klass = nil,nil
  end

  def test_fu
    refute_nil @klass
  end

  def test_mecab_version
    assert_equal(@ver, @klass.mecab_version)
  end

  def test_functions_included
    [  :mecab_new2, 
       :mecab_version, 
       :mecab_strerror,
       :mecab_destroy, 
       :mecab_set_theta,
       :mecab_set_lattice_level,
       :mecab_set_all_morphs,
       :mecab_sparse_tostr, 
       :mecab_sparse_tonode,
       :mecab_nbest_init,
       :mecab_nbest_sparse_tostr, 
       :mecab_nbest_next_tonode,
       :mecab_format_node,
       :mecab_dictionary_info 
    ].each do |f|
      assert(@klass.respond_to? f)
    end
  end
end

# Copyright (c) 2014, Brooke M. Fujita.
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
