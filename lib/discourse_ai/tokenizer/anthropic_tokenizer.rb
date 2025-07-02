# frozen_string_literal: true

module DiscourseAi
  module Tokenizer
    # Extracted from Anthropic's python SDK, compatible with first Claude versions
    class AnthropicTokenizer < BasicTokenizer
      def self.tokenizer
        @tokenizer ||=
          ::Tokenizers.from_file(
            DiscourseAi::Tokenizers.vendor_path("claude-v1-tokenization.json")
          )
      end
    end
  end
end
