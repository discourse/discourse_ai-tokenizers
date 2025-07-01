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
        expect(result_strict).to be_in([true, false])
        expect(result_non_strict).to be_in([true, false])
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
  describe DiscourseAi::Tokenizers::BertTokenizer do
    include_examples "tokenizer error handling",
                     DiscourseAi::Tokenizers::BertTokenizer
  end

  describe DiscourseAi::Tokenizers::AnthropicTokenizer do
    include_examples "tokenizer error handling",
                     DiscourseAi::Tokenizers::AnthropicTokenizer
  end

  describe DiscourseAi::Tokenizers::OpenAiTokenizer do
    include_examples "tokenizer error handling",
                     DiscourseAi::Tokenizers::OpenAiTokenizer
  end

  describe DiscourseAi::Tokenizers::AllMpnetBaseV2Tokenizer do
    include_examples "tokenizer error handling",
                     DiscourseAi::Tokenizers::AllMpnetBaseV2Tokenizer
  end

  describe DiscourseAi::Tokenizers::MultilingualE5LargeTokenizer do
    include_examples "tokenizer error handling",
                     DiscourseAi::Tokenizers::MultilingualE5LargeTokenizer
  end

  describe DiscourseAi::Tokenizers::BgeLargeEnTokenizer do
    include_examples "tokenizer error handling",
                     DiscourseAi::Tokenizers::BgeLargeEnTokenizer
  end

  describe DiscourseAi::Tokenizers::BgeM3Tokenizer do
    include_examples "tokenizer error handling",
                     DiscourseAi::Tokenizers::BgeM3Tokenizer
  end

  describe DiscourseAi::Tokenizers::Llama3Tokenizer do
    include_examples "tokenizer error handling",
                     DiscourseAi::Tokenizers::Llama3Tokenizer
  end

  describe DiscourseAi::Tokenizers::GeminiTokenizer do
    include_examples "tokenizer error handling",
                     DiscourseAi::Tokenizers::GeminiTokenizer
  end

  describe DiscourseAi::Tokenizers::QwenTokenizer do
    include_examples "tokenizer error handling",
                     DiscourseAi::Tokenizers::QwenTokenizer
  end

  describe "large input handling" do
    let(:large_text) { "Lorem ipsum dolor sit amet. " * 1000 }
    let(:tokenizers) do
      [
        DiscourseAi::Tokenizers::BertTokenizer,
        DiscourseAi::Tokenizers::AnthropicTokenizer,
        DiscourseAi::Tokenizers::OpenAiTokenizer
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
