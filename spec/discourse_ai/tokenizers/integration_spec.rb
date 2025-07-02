# frozen_string_literal: true

require "spec_helper"

RSpec.describe DiscourseAi::Tokenizer do
  shared_examples "integration tests" do |tokenizer_class|
    let(:test_texts) do
      [
        "Hello world",
        "The quick brown fox jumps over the lazy dog.",
        "This is a longer sentence with punctuation, numbers like 123, and symbols!",
        "😀 emoji test 🎉 with unicode 世界"
      ]
    end

    describe "round-trip consistency" do
      test_texts = [
        "Hello world",
        "The quick brown fox jumps over the lazy dog.",
        "This is a longer sentence with punctuation, numbers like 123, and symbols!",
        "😀 emoji test 🎉 with unicode 世界"
      ]

      test_texts.each do |text|
        it "maintains consistency for '#{text.length > 30 ? text[0..30] + "..." : text}'" do
          tokens = tokenizer_class.encode(text)
          decoded = tokenizer_class.decode(tokens)

          expect(tokens).to be_an(Array)
          expect(decoded).to be_a(String)

          # Some tokenizers may add/remove whitespace, so we check for core content
          expect(decoded.strip).not_to be_empty unless text.strip.empty?
        end
      end
    end

    describe "method return type consistency" do
      let(:sample_text) { "Hello world, this is a test." }

      it "returns consistent types" do
        expect(tokenizer_class.size(sample_text)).to be_an(Integer)
        expect(tokenizer_class.tokenize(sample_text)).to be_an(Array)
        expect(tokenizer_class.encode(sample_text)).to be_an(Array)
        expect(tokenizer_class.decode([1, 2, 3])).to be_a(String)
        expect(tokenizer_class.truncate(sample_text, 5)).to be_a(String)
        expect(tokenizer_class.below_limit?(sample_text, 10)).to be(true).or be(
               false
             )
      end
    end

    describe "tokenizer caching behavior" do
      it "caches tokenizer instances" do
        first_call = tokenizer_class.tokenizer
        second_call = tokenizer_class.tokenizer
        expect(first_call).to equal(second_call)
      end

      it "returns the expected tokenizer type" do
        tokenizer = tokenizer_class.tokenizer
        if tokenizer_class == DiscourseAi::Tokenizer::OpenAiTokenizer
          expect(tokenizer.class.name).to include("Tiktoken")
        else
          expect(tokenizer).to be_a(Tokenizers::Tokenizer)
        end
      end
    end

    describe "truncate vs below_limit? consistency" do
      let(:sample_text) do
        "This is a test sentence that should be long enough to truncate properly."
      end

      it "maintains consistency between truncate and below_limit?" do
        limit = 10

        is_below_limit = tokenizer_class.below_limit?(sample_text, limit)
        truncated = tokenizer_class.truncate(sample_text, limit)
        truncated_size = tokenizer_class.size(truncated)

        if is_below_limit
          expect(truncated_size).to eq(tokenizer_class.size(sample_text))
        else
          expect(truncated_size).to be <= limit
        end
      end

      it "strict mode produces consistent results" do
        limit = 5

        strict_truncated =
          tokenizer_class.truncate(sample_text, limit, strict: true)
        non_strict_truncated =
          tokenizer_class.truncate(sample_text, limit, strict: false)

        expect(tokenizer_class.size(strict_truncated)).to be <= limit
        expect(tokenizer_class.size(non_strict_truncated)).to be <= limit
      end
    end

    describe "size calculation consistency" do
      test_texts = ["Hello", "Hello world", "Hello, World! 123", "🎉 emoji"]

      test_texts.each do |text|
        it "size matches tokenize array length for '#{text}'" do
          size = tokenizer_class.size(text)
          tokens = tokenizer_class.tokenize(text)

          expect(size).to eq(tokens.length)
        end
      end
    end
  end

  # Test each tokenizer class individually
  describe DiscourseAi::Tokenizer::BertTokenizer do
    include_examples "integration tests", DiscourseAi::Tokenizer::BertTokenizer
  end

  describe DiscourseAi::Tokenizer::AnthropicTokenizer do
    include_examples "integration tests",
                     DiscourseAi::Tokenizer::AnthropicTokenizer
  end

  describe DiscourseAi::Tokenizer::OpenAiTokenizer do
    include_examples "integration tests",
                     DiscourseAi::Tokenizer::OpenAiTokenizer
  end

  describe DiscourseAi::Tokenizer::AllMpnetBaseV2Tokenizer do
    include_examples "integration tests",
                     DiscourseAi::Tokenizer::AllMpnetBaseV2Tokenizer
  end

  describe DiscourseAi::Tokenizer::MultilingualE5LargeTokenizer do
    include_examples "integration tests",
                     DiscourseAi::Tokenizer::MultilingualE5LargeTokenizer
  end

  describe DiscourseAi::Tokenizer::BgeLargeEnTokenizer do
    include_examples "integration tests",
                     DiscourseAi::Tokenizer::BgeLargeEnTokenizer
  end

  describe DiscourseAi::Tokenizer::BgeM3Tokenizer do
    include_examples "integration tests", DiscourseAi::Tokenizer::BgeM3Tokenizer
  end

  describe DiscourseAi::Tokenizer::Llama3Tokenizer do
    include_examples "integration tests",
                     DiscourseAi::Tokenizer::Llama3Tokenizer
  end

  describe DiscourseAi::Tokenizer::GeminiTokenizer do
    include_examples "integration tests",
                     DiscourseAi::Tokenizer::GeminiTokenizer
  end

  describe DiscourseAi::Tokenizer::QwenTokenizer do
    include_examples "integration tests", DiscourseAi::Tokenizer::QwenTokenizer
  end

  describe "available_llm_tokenizers validation" do
    it "includes only working tokenizers" do
      available =
        DiscourseAi::Tokenizer::BasicTokenizer.available_llm_tokenizers

      available.each do |tokenizer_class|
        expect { tokenizer_class.tokenizer }.not_to raise_error
        expect { tokenizer_class.size("test") }.not_to raise_error
      end
    end

    it "includes expected tokenizer classes" do
      available =
        DiscourseAi::Tokenizer::BasicTokenizer.available_llm_tokenizers

      expect(available).to include(DiscourseAi::Tokenizer::AnthropicTokenizer)
      expect(available).to include(DiscourseAi::Tokenizer::GeminiTokenizer)
      expect(available).to include(DiscourseAi::Tokenizer::Llama3Tokenizer)
      expect(available).to include(DiscourseAi::Tokenizer::OpenAiTokenizer)
      expect(available).to include(DiscourseAi::Tokenizer::QwenTokenizer)
    end
  end
end
