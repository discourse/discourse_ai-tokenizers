# frozen_string_literal: true

require "spec_helper"

RSpec.describe DiscourseAi::Tokenizers do
  shared_examples "method consistency" do |tokenizer_class|
    let(:test_text) { "Hello world, this is a test sentence!" }

    describe "tokenize vs encode method differences" do
      it "has consistent tokenize and encode methods" do
        tokenize_result = tokenizer_class.tokenize(test_text)
        encode_result = tokenizer_class.encode(test_text)

        expect(tokenize_result).to be_an(Array)
        expect(encode_result).to be_an(Array)

        # For most tokenizers, these should be different
        # tokenize returns tokens (strings), encode returns token IDs (integers)
        if tokenizer_class == DiscourseAi::Tokenizers::OpenAiTokenizer
          # OpenAI tokenizer has identical implementations - this might be a bug
          expect(tokenize_result).to eq(encode_result)
        else
          # For other tokenizers, tokenize should return tokens, encode should return IDs
          if tokenize_result.any? && encode_result.any?
            expect(tokenize_result.first.class).not_to eq(
              encode_result.first.class
            )
          end
        end
      end

      it "maintains size consistency with both methods" do
        tokenize_result = tokenizer_class.tokenize(test_text)
        encode_result = tokenizer_class.encode(test_text)
        size_result = tokenizer_class.size(test_text)

        expect(tokenize_result.length).to eq(size_result)
        expect(encode_result.length).to eq(size_result)
      end
    end

    describe "method signature consistency" do
      it "responds to all expected methods" do
        expect(tokenizer_class).to respond_to(:tokenizer)
        expect(tokenizer_class).to respond_to(:tokenize)
        expect(tokenizer_class).to respond_to(:size)
        expect(tokenizer_class).to respond_to(:decode)
        expect(tokenizer_class).to respond_to(:encode)
        expect(tokenizer_class).to respond_to(:truncate)
        expect(tokenizer_class).to respond_to(:below_limit?)
      end

      it "truncate method accepts strict parameter" do
        text = "Hello world"
        expect {
          tokenizer_class.truncate(text, 5, strict: true)
        }.not_to raise_error
        expect {
          tokenizer_class.truncate(text, 5, strict: false)
        }.not_to raise_error
      end

      it "below_limit? method accepts strict parameter" do
        text = "Hello world"
        expect {
          tokenizer_class.below_limit?(text, 5, strict: true)
        }.not_to raise_error
        expect {
          tokenizer_class.below_limit?(text, 5, strict: false)
        }.not_to raise_error
      end
    end

    describe "inheritance behavior" do
      it "inherits from BasicTokenizer" do
        expect(tokenizer_class).to be < DiscourseAi::Tokenizers::BasicTokenizer
      end

      it "overrides the tokenizer method" do
        expect { tokenizer_class.tokenizer }.not_to raise_error
      end
    end
  end

  # Test each tokenizer class individually
  describe DiscourseAi::Tokenizers::BertTokenizer do
    include_examples "method consistency",
                     DiscourseAi::Tokenizers::BertTokenizer
  end

  describe DiscourseAi::Tokenizers::AnthropicTokenizer do
    include_examples "method consistency",
                     DiscourseAi::Tokenizers::AnthropicTokenizer
  end

  describe DiscourseAi::Tokenizers::OpenAiTokenizer do
    include_examples "method consistency",
                     DiscourseAi::Tokenizers::OpenAiTokenizer

    describe "OpenAI tokenizer method overrides" do
      let(:test_text) { "Hello world 👨‍👩‍👧‍👦 test" }

      it "has custom tokenize implementation" do
        result = described_class.tokenize(test_text)
        expect(result).to be_an(Array)
        expect(result.all? { |token| token.is_a?(Integer) }).to be true
      end

      it "has custom encode implementation" do
        result = described_class.encode(test_text)
        expect(result).to be_an(Array)
        expect(result.all? { |token| token.is_a?(Integer) }).to be true
      end

      it "has identical tokenize and encode results" do
        tokenize_result = described_class.tokenize(test_text)
        encode_result = described_class.encode(test_text)
        expect(tokenize_result).to eq(encode_result)
      end

      it "has custom decode implementation" do
        tokens = described_class.encode(test_text)
        decoded = described_class.decode(tokens)
        expect(decoded).to be_a(String)
        expect(decoded).to include("Hello")
        expect(decoded).to include("world")
      end

      it "has custom truncate with unicode error handling" do
        long_text = test_text * 10
        result = described_class.truncate(long_text, 5)
        expect(result).to be_a(String)
        expect(described_class.size(result)).to be <= 5
      end

      it "has custom below_limit? implementation" do
        result = described_class.below_limit?(test_text, 100)
        expect(result).to be_in([true, false])
      end

      it "handles unicode errors in truncate" do
        unicode_text = "我喜欢吃比萨萨" * 10
        expect { described_class.truncate(unicode_text, 3) }.not_to raise_error
        result = described_class.truncate(unicode_text, 3)
        expect(described_class.size(result)).to be <= 3
      end

      it "overrides multiple methods from base class" do
        expect(described_class.method(:tokenize).owner).to eq(
          described_class.singleton_class
        )
        expect(described_class.method(:encode).owner).to eq(
          described_class.singleton_class
        )
        expect(described_class.method(:decode).owner).to eq(
          described_class.singleton_class
        )
        expect(described_class.method(:truncate).owner).to eq(
          described_class.singleton_class
        )
        expect(described_class.method(:below_limit?).owner).to eq(
          described_class.singleton_class
        )
      end
    end
  end

  describe DiscourseAi::Tokenizers::AllMpnetBaseV2Tokenizer do
    include_examples "method consistency",
                     DiscourseAi::Tokenizers::AllMpnetBaseV2Tokenizer
  end

  describe DiscourseAi::Tokenizers::MultilingualE5LargeTokenizer do
    include_examples "method consistency",
                     DiscourseAi::Tokenizers::MultilingualE5LargeTokenizer
  end

  describe DiscourseAi::Tokenizers::BgeLargeEnTokenizer do
    include_examples "method consistency",
                     DiscourseAi::Tokenizers::BgeLargeEnTokenizer
  end

  describe DiscourseAi::Tokenizers::BgeM3Tokenizer do
    include_examples "method consistency",
                     DiscourseAi::Tokenizers::BgeM3Tokenizer
  end

  describe DiscourseAi::Tokenizers::Llama3Tokenizer do
    include_examples "method consistency",
                     DiscourseAi::Tokenizers::Llama3Tokenizer
  end

  describe DiscourseAi::Tokenizers::GeminiTokenizer do
    include_examples "method consistency",
                     DiscourseAi::Tokenizers::GeminiTokenizer
  end

  describe DiscourseAi::Tokenizers::QwenTokenizer do
    include_examples "method consistency",
                     DiscourseAi::Tokenizers::QwenTokenizer
  end

  describe DiscourseAi::Tokenizers::MistralTokenizer do
    include_examples "method consistency",
                     DiscourseAi::Tokenizers::MistralTokenizer
  end

  describe "available_llm_tokenizers accuracy" do
    it "includes all working LLM tokenizers" do
      available =
        DiscourseAi::Tokenizers::BasicTokenizer.available_llm_tokenizers

      # Check that listed tokenizers actually work
      available.each do |tokenizer_class|
        expect { tokenizer_class.tokenizer }.not_to raise_error
        expect { tokenizer_class.size("test") }.not_to raise_error
      end
    end

    it "matches the class name correctly" do
      available =
        DiscourseAi::Tokenizers::BasicTokenizer.available_llm_tokenizers

      # Check for the MistralTokenizer name mismatch
      expect(available).to include(DiscourseAi::Tokenizers::MistralTokenizer)
    end

    it "excludes non-LLM tokenizers" do
      available =
        DiscourseAi::Tokenizers::BasicTokenizer.available_llm_tokenizers

      # These are embedding tokenizers, not LLM tokenizers
      expect(available).not_to include(DiscourseAi::Tokenizers::BertTokenizer)
      expect(available).not_to include(
        DiscourseAi::Tokenizers::AllMpnetBaseV2Tokenizer
      )
      expect(available).not_to include(
        DiscourseAi::Tokenizers::BgeLargeEnTokenizer
      )
      expect(available).not_to include(DiscourseAi::Tokenizers::BgeM3Tokenizer)
      expect(available).not_to include(
        DiscourseAi::Tokenizers::MultilingualE5LargeTokenizer
      )
    end
  end
end
