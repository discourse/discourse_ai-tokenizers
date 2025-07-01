# frozen_string_literal: true

module DiscourseAi
  module Tokenizers
    # Tokenizer for the mpnet based embeddings models
    class AllMpnetBaseV2Tokenizer < BasicTokenizer
      def self.tokenizer
        @tokenizer ||= ::Tokenizers.from_file("vendor/all-mpnet-base-v2.json")
      end
    end
  end
end
