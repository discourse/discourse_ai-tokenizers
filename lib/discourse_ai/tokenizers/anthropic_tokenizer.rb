# frozen_string_literal: true

module DiscourseAi
  module Tokenizers
    # Extracted from Anthropic's python SDK, compatible with first Claude versions
    class AnthropicTokenizer < BasicTokenizer
      def self.tokenizer
        @tokenizer ||=
          ::Tokenizers.from_file("vendor/claude-v1-tokenization.json")
      end
    end
  end
end
