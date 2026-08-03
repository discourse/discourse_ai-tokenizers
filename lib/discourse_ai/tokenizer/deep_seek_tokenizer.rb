# frozen_string_literal: true

module DiscourseAi
  module Tokenizer
    # Tokenizer for deepseek-ai/DeepSeek-V4-Flash-0731.
    class DeepSeekTokenizer < BasicTokenizer
      def self.tokenizer
        @tokenizer ||=
          ::Tokenizers.from_file(
            DiscourseAi::Tokenizers.vendor_path("deepseek-v4-flash-0731.json")
          )
      end
    end
  end
end
