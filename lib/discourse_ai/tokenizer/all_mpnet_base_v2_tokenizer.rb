# frozen_string_literal: true

module DiscourseAi
  module Tokenizer
    # Tokenizer for the mpnet based embeddings models
    class AllMpnetBaseV2Tokenizer < BasicTokenizer
      def self.tokenizer
        @tokenizer ||=
          ::Tokenizers.from_file(
            DiscourseAi::Tokenizers.vendor_path("all-mpnet-base-v2.json")
          )
      end
    end
  end
end
