module Natto

  # Module <tt>OptionParse</tt> encapsulates methods and behavior 
  # for parsing the various <tt>mecab</tt> options supported by
  # <tt>Natto</tt>.
  module OptionParse
    require 'optparse'

    # Mapping of mecab short-style configuration options to the <tt>mecab</tt> tagger.
    # See the <tt>mecab</tt> help for more details. 
    SUPPORTED_OPTS = { '-r' => :rcfile, 
                       '-d' => :dicdir, 
                       '-u' => :userdic, 
                       '-l' => :lattice_level, 
                       '-O' => :output_format_type, 
                       '-a' => :all_morphs,
                       '-N' => :nbest, 
                       '-p' => :partial, 
                       '-m' => :marginal, 
                       '-M' => :max_grouping_size, 
                       '-F' => :node_format, 
                       '-U' => :unk_format,
                       '-B' => :bos_format, 
                       '-E' => :eos_format, 
                       '-S' => :eon_format, 
                       '-x' => :unk_feature, 
                       '-b' => :input_buffer_size, 
                       '-C' => :allocate_sentence, 
                       '-t' => :theta, 
                       '-c' => :cost_factor }.freeze
    
    # @private
    def self.included(base)
      base.extend(ClassMethods)
    end

    # @private
    module ClassMethods
    
      # Prepares and returns a hash mapping symbols for
      # the specified, recognized MeCab options, and their
      # values. Will parse and convert string (short or
      # long argument styles) or hash. 
      def parse_mecab_options(options={})
        h = {}
        if options.is_a? String
          opts = OptionParser.new do |opts|
            opts.on('-r', '--rcfile ARG')           { |arg| h[:rcfile] = arg.strip }
            opts.on('-d', '--dicdir ARG')           { |arg| h[:dicdir] = arg.strip }
            opts.on('-u', '--userdic ARG')          { |arg| h[:userdic] = arg.strip }
            opts.on('-l', '--lattice-level ARG')    { |arg| h[:lattice_level] = arg.strip.to_i } # !deprecated in 0.99!!!
            opts.on('-O', '--output-format-type ARG') { |arg| h[:output_format_type] = arg.strip }
            opts.on('-a', '--all-morphs')           { |arg| h[:all_morphs] = true }
            opts.on('-N', '--nbest ARG')            { |arg| h[:nbest] = arg.strip.to_i }
            opts.on('-p', '--partial')              { |arg| h[:partial] = true }
            opts.on('-m', '--marginal')             { |arg| h[:marginal] = true }
            opts.on('-M', '--max-grouping-size ARG'){ |arg| h[:max_grouping_size] = arg.strip.to_i }
            opts.on('-F', '--node-format ARG')      { |arg| h[:node_format] = arg.strip }
            opts.on('-U', '--unk-format ARG')       { |arg| h[:unk_format] = arg.strip }
            opts.on('-B', '--bos-format ARG')       { |arg| h[:bos_format] = arg.strip }
            opts.on('-E', '--eos-format ARG')       { |arg| h[:eos_format] = arg.strip }
            opts.on('-S', '--eon-format ARG')       { |arg| h[:eon_format] = arg.strip }
            opts.on('-x', '--unk-feature ARG')      { |arg| h[:unk_feature] = arg.strip }
            opts.on('-b', '--input-buffer-size ARG'){ |arg| h[:input_buffer_size] = arg.strip.to_i }
            #opts.on('-M', '--open-mutable-dictionary')  { |arg| h[:open_mutable_dictionary]  = true }
            opts.on('-C', '--allocate-sentence')    { |arg| h[:allocate_sentence] = true }
            opts.on('-t', '--theta ARG')            { |arg| h[:theta] = arg.strip.to_f }
            opts.on('-c', '--cost-factor ARG')      { |arg| h[:cost_factor] = arg.strip.to_i }
          end
          opts.parse!(options.split)
        else
          SUPPORTED_OPTS.values.each do |k|
            if options.has_key?(k)
              if [ :all_morphs, :allocate_sentence ].include?(k) 
                h[k] = true
              else
                v = options[k]  
                if [ :nbest, :max_grouping_size, :input_buffer_size, :cost_factor ].include?(k)
                  h[k] = v.to_i 
                elsif k == :theta
                  h[k] = v.to_f
                elsif k == :lattice_level
                  $stderr.print(":lattice-level is DEPRECATED, please use :marginal or :nbest\n")
                  h[k] = v.to_i 
                  #raise MeCabError.new(":lattice-level is DEPRECATED, please use :marginal or :nbest")
                else 
                  h[k] = v
                end
              end
            end
          end
        end
        raise MeCabError.new("Invalid N value") if h[:nbest] && (h[:nbest] < 1 || h[:nbest] > 512)
        h
      end

      # Returns a string-representation of the options to
      # be passed in the construction of the <tt>mecab</tt> tagger.
      #
      # @param [Hash] options 
      # @return [String] representation of the options to the <tt>mecab</tt> tagger
      def build_options_str(options={})
        opt = []
        SUPPORTED_OPTS.values.each do |k|
          if options.has_key? k
            key = k.to_s.gsub('_', '-')  
            if %w( all-morphs allocate-sentence ).include? key
              opt << "--#{key}" if options[k]==true
            else
              opt << "--#{key}=#{options[k]}"
            end
          end
        end
        opt.empty? ? "" : opt.join(" ") 
      end
    end
  end
end
