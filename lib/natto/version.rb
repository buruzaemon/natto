# coding: utf-8

# <tt>Natto</tt> is the namespace for objects that provide
# a binding to the <tt>mecab</tt> tagger and related resources.
#
# <tt>Natto::MeCab</tt> is a wrapper class for the <tt>mecab</tt> 
# tagger.
#
# <tt>Natto::MeCabStruct</tt> is a base class for a <tt>mecab</tt>
# struct.
#
# <tt>Natto::MeCabNode</tt> is a wrapper for the struct representing
# a <tt>mecab</tt>-parsed node.
#
# <tt>Natto::DictionaryInfo</tt> is a wrapper for the struct 
# representing a <tt>Natto::MeCab</tt> instance's related 
# dictionary information.
#
# <tt>Natto::MeCabError</tt> is a general error class for the 
# <tt>Natto</tt> module.
#
# Module <tt>Natto::Binding</tt> encapsulates methods and behavior 
# which are made available via <tt>FFI</tt> bindings to <tt>mecab</tt>.
module Natto
  # Version string for this Rubygem.
  VERSION = "0.9.4"
end
