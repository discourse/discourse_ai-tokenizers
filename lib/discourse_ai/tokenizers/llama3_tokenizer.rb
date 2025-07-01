# frozen_string_literal: true

module DiscourseAi
  module Tokenizers
    # Tokenizer from Llama3, popular open weights LLM
    class Llama3Tokenizer < BasicTokenizer
      def self.tokenizer
        @tokenizer ||=
          ::Tokenizers.from_file("vendor/Meta-Llama-3-70B-Instruct.json")
      end
    end
  end
end
