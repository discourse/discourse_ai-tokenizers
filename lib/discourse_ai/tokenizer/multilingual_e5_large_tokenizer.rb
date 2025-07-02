# frozen_string_literal: true

module DiscourseAi
  module Tokenizer
    # Tokenizer from multilingual-e5-large, first multilingual embeddings model used in Discourse
    class MultilingualE5LargeTokenizer < BasicTokenizer
      def self.tokenizer
        @tokenizer ||=
          ::Tokenizers.from_file(
            DiscourseAi::Tokenizers.vendor_path("multilingual-e5-large.json")
          )
      end
    end
  end
end
