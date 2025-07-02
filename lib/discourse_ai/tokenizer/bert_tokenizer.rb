# frozen_string_literal: true

module DiscourseAi
  module Tokenizer
    # Bert tokenizer, useful for lots of embeddings and small classification models
    class BertTokenizer < BasicTokenizer
      def self.tokenizer
        @tokenizer ||=
          ::Tokenizers.from_file(
            DiscourseAi::Tokenizers.vendor_path("bert-base-uncased.json")
          )
      end
    end
  end
end
