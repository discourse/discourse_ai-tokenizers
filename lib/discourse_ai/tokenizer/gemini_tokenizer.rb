# frozen_string_literal: true

module DiscourseAi
  module Tokenizer
    # Tokenizer from Gemma3, which is said to be the same for Gemini
    class GeminiTokenizer < BasicTokenizer
      def self.tokenizer
        @tokenizer ||=
          ::Tokenizers.from_file(
            DiscourseAi::Tokenizers.vendor_path("gemma3.json")
          )
      end
    end
  end
end
