# coding: utf-8

# `Natto` is the namespace for objects that provide
# a binding to the `mecab` tagger and related resources.
#
# `Natto::MeCab` is a wrapper class for the `mecab` 
# tagger.
#
# `Natto::MeCabStruct` is a base class for a `mecab`
# struct.
#
# `Natto::MeCabNode` is a wrapper for the struct representing
# a `mecab`-parsed node.
#
# `Natto::DictionaryInfo` is a wrapper for the struct 
# representing a `Natto::MeCab` instance's related 
# dictionary information.
#
# `Natto::MeCabError` is a general error class for the 
# `Natto` module.
#
# Module `Natto::Binding` encapsulates methods and behavior 
# which are made available via `FFI` bindings to `mecab`.
#
# Module `OptionParse` encapsulates methods and behavior 
# for parsing the various `mecab` options supported by
# `Natto`.
module Natto
  # Version string for this Rubygem.
  VERSION = "0.9.6"
end
