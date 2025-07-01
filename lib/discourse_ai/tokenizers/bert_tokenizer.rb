# frozen_string_literal: true

module DiscourseAi
  module Tokenizers
    # Bert tokenizer, useful for lots of embeddings and small classification models
    class BertTokenizer < BasicTokenizer
      def self.tokenizer
        @tokenizer ||= ::Tokenizers.from_file("vendor/bert-base-uncased.json")
      end
    end
  end
end
