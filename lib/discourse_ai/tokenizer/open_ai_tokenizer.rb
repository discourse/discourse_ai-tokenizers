# frozen_string_literal: true

module DiscourseAi
  module Tokenizer
    # Wrapper for OpenAI tokenizer library for compatibility with Discourse AI API
    class OpenAiTokenizer < BasicTokenizer
      # tiktoken-rs uses fancy-regex which can stack overflow on large inputs
      # due to catastrophic backtracking (github.com/openai/tiktoken/issues/245).
      # Chunking at whitespace boundaries prevents this while preserving accuracy.
      SAFE_CHUNK_SIZE = 50_000

      class << self
        def tokenizer
          @tokenizer ||= Tiktoken.get_encoding("o200k_base")
        end

        def tokenize(text)
          safe_encode(text)
        end

        def encode(text)
          safe_encode(text)
        end

        def decode(token_ids)
          tokenizer.decode(token_ids)
        rescue Tiktoken::UnicodeError
          token_ids = token_ids.dup

          # this easy case, we started with a valid sequnce but truncated it on an invalid boundary
          # work backwards removing tokens until we can decode again
          tries = 4
          while tries > 0
            begin
              token_ids.pop
              return tokenizer.decode(token_ids)
            rescue Tiktoken::UnicodeError
              tries -= 1
            end
          end

          # at this point we may have a corrupted sequence so just decode what we can
          token_ids
            .map do |id|
              begin
                tokenizer.decode([id])
              rescue Tiktoken::UnicodeError
                ""
              end
            end
            .join
        end

        def truncate(text, max_length, strict: false)
          return "" if max_length <= 0

          # fast track common case, /2 to handle unicode chars
          # than can take more than 1 token per char
          return text if !strict && text.size < max_length / 2

          # Take tokens up to max_length, decode, then ensure we don't exceed limit
          truncated_tokens = tokenize(text).take(max_length)
          truncated_text = decode(truncated_tokens)

          # If re-encoding exceeds the limit, we need to further truncate
          while tokenize(truncated_text).length > max_length
            truncated_tokens = truncated_tokens[0...-1]
            truncated_text = decode(truncated_tokens)
            break if truncated_tokens.empty?
          end

          truncated_text
        end

        def below_limit?(text, limit, strict: false)
          # fast track common case, /2 to handle unicode chars
          # than can take more than 1 token per char
          return true if !strict && text.size < limit / 2

          safe_encode(text).length < limit
        end

        private

        def safe_encode(text)
          if !text.is_a?(String) || text.size <= SAFE_CHUNK_SIZE
            return tokenizer.encode(text)
          end

          tokens = []
          offset = 0
          while offset < text.size
            chunk_end = offset + SAFE_CHUNK_SIZE

            if chunk_end < text.size
              # Split at a whitespace boundary to preserve tokenization accuracy
              break_point = text.rindex(/\s/, chunk_end)
              chunk_end = break_point if break_point && break_point > offset
            else
              chunk_end = text.size
            end

            tokens.concat(tokenizer.encode(text[offset...chunk_end]))
            offset = chunk_end
          end

          tokens
        end
      end
    end

    OpenAiO200kTokenizer = OpenAiTokenizer
  end
end
