# frozen_string_literal: true

module DiscourseAi
  module Tokenizers
    # Tokenizer from multilingual-e5-large, first multilingual embeddings model used in Discourse
    class MultilingualE5LargeTokenizer < BasicTokenizer
      def self.tokenizer
        @tokenizer ||=
          ::Tokenizers.from_file("vendor/multilingual-e5-large.json")
      end
    end
  end
end
