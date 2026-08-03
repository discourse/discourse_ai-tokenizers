# frozen_string_literal: true

module DiscourseAi
  module Tokenizer
    # Base class for tokenizers to inherit from
    class BasicTokenizer
      class << self
        def available_llm_tokenizers
          [
            DiscourseAi::Tokenizer::AnthropicTokenizer,
            DiscourseAi::Tokenizer::DeepSeekTokenizer,
            DiscourseAi::Tokenizer::GeminiTokenizer,
            DiscourseAi::Tokenizer::Llama3Tokenizer,
            DiscourseAi::Tokenizer::MistralTokenizer,
            DiscourseAi::Tokenizer::OpenAiTokenizer,
            DiscourseAi::Tokenizer::QwenTokenizer
          ]
        end

        def tokenizer
          raise NotImplementedError
        end

        def tokenize(text)
          tokenizer.encode(normalize_text(text)).tokens
        end

        def size(text)
          tokenize(text).size
        end

        def decode(token_ids)
          tokenizer.decode(token_ids)
        end

        def encode(text)
          tokenizer.encode(normalize_text(text)).ids
        end

        def truncate(text, max_length, strict: false)
          return "" if max_length <= 0

          text = normalize_text(text)

          # fast track common case, /2 to handle unicode chars
          # than can take more than 1 token per char
          return text if !strict && text.size < max_length / 2

          # Take tokens up to max_length, decode, then ensure we don't exceed limit
          truncated_tokens = tokenizer.encode(text).ids.take(max_length)
          truncated_text = normalize_text(tokenizer.decode(truncated_tokens))

          # If re-encoding exceeds the limit, we need to further truncate
          while tokenizer.encode(truncated_text).ids.length > max_length
            truncated_tokens = truncated_tokens[0...-1]
            truncated_text = normalize_text(tokenizer.decode(truncated_tokens))
            break if truncated_tokens.empty?
          end

          normalize_text(truncated_text)
        end

        def below_limit?(text, limit, strict: false)
          text = normalize_text(text)

          # fast track common case, /2 to handle unicode chars
          # than can take more than 1 token per char
          return true if !strict && text.size < limit / 2

          tokenizer.encode(text).ids.length < limit
        end

        private

        def normalize_text(text)
          return text unless text.is_a?(String)

          # Fast path: avoid allocations for the common valid UTF-8 case.
          if text.encoding == Encoding::UTF_8 && text.valid_encoding?
            return text
          end

          if text.encoding == Encoding::ASCII_8BIT
            normalized = text.dup
            normalized.force_encoding(Encoding::UTF_8)
          elsif text.encoding != Encoding::UTF_8
            normalized = text.encode(Encoding::UTF_8)
          else
            normalized = text
          end

          normalized.valid_encoding? ? normalized : normalized.scrub
        rescue Encoding::UndefinedConversionError,
               Encoding::InvalidByteSequenceError
          text.encode(Encoding::UTF_8, invalid: :replace, undef: :replace)
        end
      end
    end
  end
end
