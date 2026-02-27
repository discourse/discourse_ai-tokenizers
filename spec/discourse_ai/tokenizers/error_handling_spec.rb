# frozen_string_literal: true

require "spec_helper"

RSpec.describe DiscourseAi::Tokenizers do
  shared_examples "tokenizer error handling" do |tokenizer_class|
    describe "nil input handling" do
      it "handles nil input for #size" do
        expect { tokenizer_class.size(nil) }.to raise_error(TypeError)
      end

      it "handles nil input for #tokenize" do
        expect { tokenizer_class.tokenize(nil) }.to raise_error(TypeError)
      end

      it "handles nil input for #encode" do
        expect { tokenizer_class.encode(nil) }.to raise_error(TypeError)
      end

      it "handles nil input for #truncate" do
        expect { tokenizer_class.truncate(nil, 10) }.to raise_error(
          NoMethodError
        )
      end

      it "handles nil input for #below_limit?" do
        expect { tokenizer_class.below_limit?(nil, 10) }.to raise_error(
          NoMethodError
        )
      end
    end

    describe "empty string handling" do
      it "handles empty string for #size" do
        expect(tokenizer_class.size("")).to eq(0).or be > 0
      end

      it "handles empty string for #tokenize" do
        result = tokenizer_class.tokenize("")
        expect(result).to be_an(Array)
      end

      it "handles empty string for #encode" do
        result = tokenizer_class.encode("")
        expect(result).to be_an(Array)
      end

      it "handles empty string for #truncate" do
        result = tokenizer_class.truncate("", 10)
        expect(result).to eq("")
      end

      it "handles empty string for #below_limit?" do
        result = tokenizer_class.below_limit?("", 10)
        expect(result).to be true
      end
    end

    describe "unicode and emoji handling" do
      let(:unicode_text) { "Hello 世界 🌍 👨‍👩‍👧‍👦" }
      let(:emoji_text) { "🎉🎊🥳😀😃😄😁😆😅🤣😂" }

      it "handles unicode text" do
        expect { tokenizer_class.size(unicode_text) }.not_to raise_error
        expect(tokenizer_class.size(unicode_text)).to be > 0
      end

      it "handles emoji text" do
        expect { tokenizer_class.size(emoji_text) }.not_to raise_error
        expect(tokenizer_class.size(emoji_text)).to be > 0
      end

      it "maintains unicode in round-trip encode/decode" do
        tokens = tokenizer_class.encode(unicode_text)
        decoded = tokenizer_class.decode(tokens)
        # For BERT-like tokenizers, expect lowercase and partial unicode
        if tokenizer_class.name.include?("Bert") ||
             tokenizer_class.name.include?("AllMpnet") ||
             tokenizer_class.name.include?("BgeLarge")
          expect(decoded.downcase).to include("hello")
          expect(decoded).to include("世")
        else
          expect(decoded).to include("Hello")
          expect(decoded).to include("世界")
        end
      end

      it "handles truncation at all token boundaries without raising" do
        text = "日本語テスト 🎉 中文测试 العربية"
        token_count = tokenizer_class.size(text)

        (1..token_count).each do |i|
          expect {
            tokenizer_class.truncate(text, i, strict: true)
          }.not_to raise_error
        end
      end

      it "returns valid UTF-8 strings when truncating multi-byte characters" do
        text = "日本語テスト 🎉 中文测试 العربية"

        result = tokenizer_class.truncate(text, 5, strict: true)
        expect(result).to be_a(String)
        expect(result.valid_encoding?).to be true
      end

      it "handles ASCII-8BIT text in truncate" do
        utf8_text = "日本語テスト 🎉 中文测试 العربية"
        text = utf8_text.dup.force_encoding(
          Encoding::ASCII_8BIT
        )

        limit = 5
        utf8_result = tokenizer_class.truncate(utf8_text, limit, strict: true)
        result = tokenizer_class.truncate(text, limit, strict: true)

        expect(result).to be_a(String)
        expect(result).to eq(utf8_result)
        expect(result.encoding).to eq(Encoding::UTF_8)
        expect(result.valid_encoding?).to be true
        expect(tokenizer_class.size(result)).to be <= limit
      end

      it "handles ASCII-8BIT text in below_limit?" do
        utf8_text = "日本語テスト 🎉 中文测试 العربية"
        text = utf8_text.dup.force_encoding(
          Encoding::ASCII_8BIT
        )
        token_count = tokenizer_class.size(utf8_text)
        limits = [1, [token_count - 1, 1].max, token_count, token_count + 1].uniq

        limits.each do |limit|
          expect(tokenizer_class.below_limit?(text, limit, strict: true)).to eq(
            tokenizer_class.below_limit?(utf8_text, limit, strict: true)
          )
          expect(tokenizer_class.below_limit?(text, limit, strict: false)).to eq(
            tokenizer_class.below_limit?(utf8_text, limit, strict: false)
          )
        end
      end

      it "always returns valid UTF-8 from chained truncation" do
        invalid_utf8 = "日本語テスト".bytes[0..-2].pack("C*").force_encoding(
          Encoding::UTF_8
        )
        expect(invalid_utf8.valid_encoding?).to be false

        first = tokenizer_class.truncate(invalid_utf8, 5, strict: true)
        second = tokenizer_class.truncate(first, 3, strict: true)

        [first, second].each do |result|
          expect(result).to be_a(String)
          expect(result.encoding).to eq(Encoding::UTF_8)
          expect(result.valid_encoding?).to be true
        end

        expect(tokenizer_class.size(first)).to be <= 5
        expect(tokenizer_class.size(second)).to be <= 3
      end
    end

    describe "pathological encoding handling" do
      let(:valid_utf8_text) { "Cafe 日本語 🎉" }
      let(:binary_utf8_text) do
        valid_utf8_text.dup.force_encoding(Encoding::ASCII_8BIT)
      end
      let(:invalid_utf8) { "abc\xE2\x82".b.force_encoding(Encoding::UTF_8) }
      let(:invalid_binary_text) { "bad\xFF\xFEtext\xC3".b }
      let(:latin1_text) { "caf\xe9".dup.force_encoding(Encoding::ISO_8859_1) }
      let(:normalized_cases) do
        [
          [binary_utf8_text, valid_utf8_text],
          [invalid_utf8, invalid_utf8.scrub],
          [
            invalid_binary_text,
            invalid_binary_text.dup.force_encoding(Encoding::UTF_8).scrub
          ],
          [latin1_text, "café"]
        ]
      end

      it "normalizes tokenize, size, and encode inputs" do
        normalized_cases.each do |input, normalized|
          expect(tokenizer_class.tokenize(input)).to eq(
            tokenizer_class.tokenize(normalized)
          )
          expect(tokenizer_class.size(input)).to eq(tokenizer_class.size(normalized))
          expect(tokenizer_class.encode(input)).to eq(
            tokenizer_class.encode(normalized)
          )
        end
      end

      it "normalizes truncate and below_limit? inputs" do
        normalized_cases.each do |input, normalized|
          token_count = tokenizer_class.size(normalized)
          limits = [1, [token_count - 1, 1].max, token_count, token_count + 1].uniq

          strict_truncation = tokenizer_class.truncate(
            input,
            [token_count, 1].max,
            strict: true
          )
          expect(strict_truncation.encoding).to eq(Encoding::UTF_8)
          expect(strict_truncation.valid_encoding?).to be true
          expect(strict_truncation).to eq(
            tokenizer_class.truncate(normalized, [token_count, 1].max, strict: true)
          )

          limits.each do |limit|
            expect(tokenizer_class.below_limit?(input, limit, strict: true)).to eq(
              tokenizer_class.below_limit?(normalized, limit, strict: true)
            )
            expect(tokenizer_class.below_limit?(input, limit, strict: false)).to eq(
              tokenizer_class.below_limit?(normalized, limit, strict: false)
            )
          end
        end
      end
    end

    describe "edge case parameters" do
      let(:sample_text) { "Hello world, this is a test sentence." }

      it "handles zero limit in truncate" do
        result = tokenizer_class.truncate(sample_text, 0)
        expect(result).to eq("")
      end

      it "handles negative limit in truncate" do
        result = tokenizer_class.truncate(sample_text, -1)
        expect(result).to eq("")
      end

      it "handles zero limit in below_limit?" do
        result = tokenizer_class.below_limit?(sample_text, 0)
        expect(result).to be false
      end

      it "handles very large limit in below_limit?" do
        result = tokenizer_class.below_limit?(sample_text, 10_000)
        expect(result).to be true
      end

      it "handles strict mode in truncate" do
        result_strict = tokenizer_class.truncate(sample_text, 5, strict: true)
        result_non_strict =
          tokenizer_class.truncate(sample_text, 5, strict: false)
        expect(result_strict).to be_a(String)
        expect(result_non_strict).to be_a(String)
      end

      it "handles strict mode in below_limit?" do
        result_strict =
          tokenizer_class.below_limit?(sample_text, 5, strict: true)
        result_non_strict =
          tokenizer_class.below_limit?(sample_text, 5, strict: false)
        expect(result_strict).to be(true).or be(false)
        expect(result_non_strict).to be(true).or be(false)
      end
    end

    describe "decode error handling" do
      it "handles empty token array" do
        result = tokenizer_class.decode([])
        expect(result).to eq("").or be_a(String)
      end

      it "handles invalid token IDs gracefully" do
        expect {
          tokenizer_class.decode([999_999, 888_888, 777_777])
        }.not_to raise_error
      end
    end
  end

  # Test each tokenizer class individually
  describe DiscourseAi::Tokenizer::BertTokenizer do
    include_examples "tokenizer error handling",
                     DiscourseAi::Tokenizer::BertTokenizer
  end

  describe DiscourseAi::Tokenizer::AnthropicTokenizer do
    include_examples "tokenizer error handling",
                     DiscourseAi::Tokenizer::AnthropicTokenizer
  end

  describe DiscourseAi::Tokenizer::OpenAiTokenizer do
    include_examples "tokenizer error handling",
                     DiscourseAi::Tokenizer::OpenAiTokenizer

    describe "truncation correctness" do
      let(:tokenizer) { DiscourseAi::Tokenizer::OpenAiTokenizer }

      it "truncates simple ASCII text correctly" do
        text = "Hello world this is a test"
        result = tokenizer.truncate(text, 3, strict: true)

        expect(result).to eq("Hello world this")
        expect(tokenizer.size(result)).to be <= 3
      end

      it "truncates multi-byte UTF-8 text correctly" do
        text = "a 🎉 a 🎉 a"

        result = tokenizer.truncate(text, 2, strict: true)
        expect(result).to eq("a")

        result = tokenizer.truncate(text, 3, strict: true)
        expect(result).to eq("a 🎉")

        result = tokenizer.truncate(text, 5, strict: true)
        expect(result).to eq("a 🎉 a")
      end

      it "never exceeds the requested token limit" do
        text = "日本語テスト 🎉 中文测试 العربية"

        (1..tokenizer.size(text)).each do |limit|
          result = tokenizer.truncate(text, limit, strict: true)
          expect(tokenizer.size(result)).to be <= limit
        end
      end

      it "preserves text prefix when truncating" do
        text = "Hello 世界 test"
        result = tokenizer.truncate(text, 2, strict: true)

        expect(text).to start_with(result)
      end
    end
  end

  describe DiscourseAi::Tokenizer::AllMpnetBaseV2Tokenizer do
    include_examples "tokenizer error handling",
                     DiscourseAi::Tokenizer::AllMpnetBaseV2Tokenizer
  end

  describe DiscourseAi::Tokenizer::MultilingualE5LargeTokenizer do
    include_examples "tokenizer error handling",
                     DiscourseAi::Tokenizer::MultilingualE5LargeTokenizer
  end

  describe DiscourseAi::Tokenizer::BgeLargeEnTokenizer do
    include_examples "tokenizer error handling",
                     DiscourseAi::Tokenizer::BgeLargeEnTokenizer
  end

  describe DiscourseAi::Tokenizer::BgeM3Tokenizer do
    include_examples "tokenizer error handling",
                     DiscourseAi::Tokenizer::BgeM3Tokenizer
  end

  describe DiscourseAi::Tokenizer::Llama3Tokenizer do
    include_examples "tokenizer error handling",
                     DiscourseAi::Tokenizer::Llama3Tokenizer
  end

  describe DiscourseAi::Tokenizer::GeminiTokenizer do
    include_examples "tokenizer error handling",
                     DiscourseAi::Tokenizer::GeminiTokenizer
  end

  describe DiscourseAi::Tokenizer::QwenTokenizer do
    include_examples "tokenizer error handling",
                     DiscourseAi::Tokenizer::QwenTokenizer
  end

  describe "large input handling" do
    let(:large_text) { "Lorem ipsum dolor sit amet. " * 1000 }
    let(:tokenizers) do
      [
        DiscourseAi::Tokenizer::BertTokenizer,
        DiscourseAi::Tokenizer::AnthropicTokenizer,
        DiscourseAi::Tokenizer::OpenAiTokenizer
      ]
    end

    it "handles large text input across multiple tokenizers" do
      tokenizers.each do |tokenizer_class|
        expect { tokenizer_class.size(large_text) }.not_to raise_error
        expect(tokenizer_class.size(large_text)).to be > 1000
      end
    end
  end
end
