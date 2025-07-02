# frozen_string_literal: true

module DiscourseAi
  module Tokenizer
    # Tokenizer from Qwen3 LLM series. Also compatible with their embedding models
    class QwenTokenizer < BasicTokenizer
      def self.tokenizer
        @tokenizer ||=
          ::Tokenizers.from_file(
            DiscourseAi::Tokenizers.vendor_path("qwen3.json")
          )
      end
    end
  end
end
