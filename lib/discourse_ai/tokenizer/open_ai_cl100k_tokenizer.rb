# frozen_string_literal: true

module DiscourseAi
  module Tokenizer
    # Wrapper for OpenAI tokenizer library for compatibility with Discourse AI API
    class OpenAiCl100kTokenizer < OpenAiTokenizer
      class << self
        def tokenizer
          @tokenizer ||= Tiktoken.get_encoding("cl100k_base")
        end
      end
    end
  end
end
