# frozen_string_literal: true

module DiscourseAi
  module Tokenizers
    # Tokenizer used in bge-large-en-v1.5, the most common embeddings model used for Discourse
    class BgeLargeEnTokenizer < BasicTokenizer
      def self.tokenizer
        @tokenizer ||= ::Tokenizers.from_file("vendor/bge-large-en.json")
      end
    end
  end
end
