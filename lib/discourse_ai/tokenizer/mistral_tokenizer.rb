# frozen_string_literal: true

module DiscourseAi
  module Tokenizer
    # Tokenizer from Mistral Small 2503 LLM
    class MistralTokenizer < BasicTokenizer
      def self.tokenizer
        @tokenizer ||=
          ::Tokenizers.from_file(
            DiscourseAi::Tokenizers.vendor_path(
              "mistral-small-3.1-24b-2503.json"
            )
          )
      end
    end
  end
end
