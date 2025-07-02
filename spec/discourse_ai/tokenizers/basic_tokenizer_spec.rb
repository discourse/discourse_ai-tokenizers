# frozen_string_literal: true

require "spec_helper"

RSpec.describe DiscourseAi::Tokenizer::BasicTokenizer do
  describe ".available_llm_tokenizers" do
    it "returns an array of tokenizer classes" do
      tokenizers = described_class.available_llm_tokenizers
      expect(tokenizers).to be_an(Array)
      expect(tokenizers).not_to be_empty
    end

    it "includes expected tokenizer classes" do
      tokenizers = described_class.available_llm_tokenizers
      expect(tokenizers).to include(DiscourseAi::Tokenizer::AnthropicTokenizer)
      expect(tokenizers).to include(DiscourseAi::Tokenizer::GeminiTokenizer)
      expect(tokenizers).to include(DiscourseAi::Tokenizer::Llama3Tokenizer)
      expect(tokenizers).to include(DiscourseAi::Tokenizer::OpenAiTokenizer)
      expect(tokenizers).to include(DiscourseAi::Tokenizer::QwenTokenizer)
    end

    it "returns only class objects" do
      tokenizers = described_class.available_llm_tokenizers
      tokenizers.each do |tokenizer|
        expect(tokenizer).to be_a(Class)
        expect(tokenizer).to be < described_class
      end
    end
  end

  describe ".tokenizer" do
    it "raises NotImplementedError when called directly" do
      expect { described_class.tokenizer }.to raise_error(NotImplementedError)
    end
  end

  describe ".tokenize" do
    it "raises NotImplementedError when called directly" do
      expect { described_class.tokenize("hello") }.to raise_error(
        NotImplementedError
      )
    end
  end

  describe ".size" do
    it "raises NotImplementedError when called directly" do
      expect { described_class.size("hello") }.to raise_error(
        NotImplementedError
      )
    end
  end

  describe ".decode" do
    it "raises NotImplementedError when called directly" do
      expect { described_class.decode([1, 2, 3]) }.to raise_error(
        NotImplementedError
      )
    end
  end

  describe ".encode" do
    it "raises NotImplementedError when called directly" do
      expect { described_class.encode("hello") }.to raise_error(
        NotImplementedError
      )
    end
  end

  describe ".truncate" do
    it "raises NotImplementedError when called directly" do
      expect { described_class.truncate("hello world", 5) }.to raise_error(
        NotImplementedError
      )
    end
  end

  describe ".below_limit?" do
    it "raises NotImplementedError when called directly" do
      expect { described_class.below_limit?("hello world", 10) }.to raise_error(
        NotImplementedError
      )
    end
  end
end
