# coding: utf-8

module Natto
  class MeCab
    if RUBY_VERSION.to_f >= 1.9
      alias_method :orig_parse, :parse
      def parse(str)
        orig_parse(str).force_encoding(__ENCODING__)
      end
    end
  end
end
