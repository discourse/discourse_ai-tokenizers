# frozen_string_literal: true

module DiscourseAi
  module Tokenizers
    # Tokenizer used in bge-m3, a capable multilingual long context embeddings model.
    class BgeM3Tokenizer < BasicTokenizer
      def self.tokenizer
        @tokenizer ||= ::Tokenizers.from_file("vendor/bge-m3.json")
      end
    end
  end
end
