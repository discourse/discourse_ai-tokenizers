# frozen_string_literal: true

module DiscourseAi
  module Tokenizers
    # Tokenizer from Gemma3, which is said to be the same for Gemini
    class GeminiTokenizer < BasicTokenizer
      def self.tokenizer
        @tokenizer ||= ::Tokenizers.from_file("vendor/gemma3.json")
      end
    end
  end
end
