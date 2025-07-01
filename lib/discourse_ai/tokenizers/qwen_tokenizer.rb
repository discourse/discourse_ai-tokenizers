# frozen_string_literal: true

module DiscourseAi
  module Tokenizers
    # Tokenizer from Qwen3 LLM series. Also compatible with their embedding models
    class QwenTokenizer < BasicTokenizer
      def self.tokenizer
        @tokenizer ||= ::Tokenizers.from_file("vendor/qwen3.json")
      end
    end
  end
end
