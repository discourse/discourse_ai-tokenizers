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
        text = "日本語テスト 🎉 中文测试 العربية"

        result = tokenizer.truncate(text, 4, strict: true)
        expect(result).to eq("日本語テスト")
        expect(tokenizer.size(result)).to eq(4)

        result = tokenizer.truncate(text, 7, strict: true)
        expect(result).to eq("日本語テスト 🎉 中文")
        expect(tokenizer.size(result)).to eq(7)
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
