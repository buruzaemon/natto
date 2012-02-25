# coding: utf-8
module Natto
  module Utils
    # @private
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def force_enc(str)
        str.force_encoding(Encoding.default_external) if str.respond_to?(:encoding) && str.encoding!=Encoding.default_external
        str
      end
    end
  end
end
