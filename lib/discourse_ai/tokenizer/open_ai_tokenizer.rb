# frozen_string_literal: true

module DiscourseAi
  module Tokenizer
    # Wrapper for OpenAI tokenizer library for compatibility with Discourse AI API
    class OpenAiTokenizer < BasicTokenizer
      class << self
        def tokenizer
          @tokenizer ||= Tiktoken.get_encoding("o200k_base")
        end

        def tokenize(text)
          tokenizer.encode(text)
        end

        def encode(text)
          tokenizer.encode(text)
        end

        def decode(token_ids)
          tokenizer.decode(token_ids)
        rescue Tiktoken::UnicodeError => e
          # Handle invalid token IDs gracefully by returning empty string
          ""
        end

        def truncate(text, max_length, strict: false)
          return "" if max_length <= 0

          # fast track common case, /2 to handle unicode chars
          # than can take more than 1 token per char
          return text if !strict && text.size < max_length / 2

          # Take tokens up to max_length, decode, then ensure we don't exceed limit
          truncated_tokens = tokenize(text).take(max_length)
          truncated_text = tokenizer.decode(truncated_tokens)

          # If re-encoding exceeds the limit, we need to further truncate
          while tokenize(truncated_text).length > max_length
            truncated_tokens = truncated_tokens[0...-1]
            truncated_text = tokenizer.decode(truncated_tokens)
            break if truncated_tokens.empty?
          end

          truncated_text
        end

        def below_limit?(text, limit, strict: false)
          # fast track common case, /2 to handle unicode chars
          # than can take more than 1 token per char
          return true if !strict && text.size < limit / 2

          tokenizer.encode(text).length < limit
        end
      end
    end

    OpenAiO200kTokenizer = OpenAiTokenizer
  end
end
