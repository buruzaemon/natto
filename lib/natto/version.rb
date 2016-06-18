# coding: utf-8

# `Natto` is the namespace for objects that provide
# a binding to MeCab and an API for the `Tagger`,
# `Node` and `Lattice` objects.
#
# `Natto::MeCab` is a wrapper class for the MeCab Tagger.
#
# `Natto::MeCabStruct` is a base class for a MeCab struct.
#
# `Natto::MeCabNode` is a wrapper for the struct representing
# a MeCab `Node`.
#
# `Natto::DictionaryInfo` is a wrapper for the struct 
# representing a `Natto::MeCab` instance's related 
# dictionary information.
#
# `Natto::MeCabError` is a general error class for the 
# `Natto` module.
#
# Module `Natto::Binding` encapsulates methods and behavior 
# which are made available via `FFI` bindings to MeCab.
#
# Module `OptionParse` encapsulates methods and behavior 
# for parsing the various MeCab options supported by
# `Natto`.
module Natto
  # Version string for this Rubygem.
  VERSION = "1.1.1"
end

# Copyright (c) 2016, Brooke M. Fujita.
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
