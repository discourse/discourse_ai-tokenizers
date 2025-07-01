# frozen_string_literal: true

module DiscourseAi
  module Tokenizers
    # Base class for tokenizers to inherit from
    class BasicTokenizer
      class << self
        def available_llm_tokenizers
          [
            DiscourseAi::Tokenizers::AnthropicTokenizer,
            DiscourseAi::Tokenizers::GeminiTokenizer,
            DiscourseAi::Tokenizers::Llama3Tokenizer,
            DiscourseAi::Tokenizers::MistralTokenizer,
            DiscourseAi::Tokenizers::OpenAiTokenizer,
            DiscourseAi::Tokenizers::QwenTokenizer
          ]
        end

        def tokenizer
          raise NotImplementedError
        end

        def tokenize(text)
          tokenizer.encode(text).tokens
        end

        def size(text)
          tokenize(text).size
        end

        def decode(token_ids)
          tokenizer.decode(token_ids)
        end

        def encode(tokens)
          tokenizer.encode(tokens).ids
        end

        def truncate(text, max_length, strict: false)
          return "" if max_length <= 0

          # fast track common case, /2 to handle unicode chars
          # than can take more than 1 token per char
          return text if !strict && text.size < max_length / 2

          # Take tokens up to max_length, decode, then ensure we don't exceed limit
          truncated_tokens = tokenizer.encode(text).ids.take(max_length)
          truncated_text = tokenizer.decode(truncated_tokens)

          # If re-encoding exceeds the limit, we need to further truncate
          while tokenizer.encode(truncated_text).ids.length > max_length
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

          tokenizer.encode(text).ids.length < limit
        end
      end
    end
  end
end
