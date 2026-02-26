# frozen_string_literal: true

require "spec_helper"

RSpec.describe DiscourseAi::Tokenizer::OpenAiTokenizer do
  let(:chunk_size) { described_class::SAFE_CHUNK_SIZE }

  shared_examples "safe encoding" do |tokenizer_class|
    describe "text under chunk size" do
      it "encodes normally without chunking" do
        text = "Hello world, this is a normal sentence."
        raw_tokenizer = tokenizer_class.tokenizer

        expect(tokenizer_class.encode(text)).to eq(raw_tokenizer.encode(text))
      end
    end

    describe "large text with whitespace" do
      it "produces identical tokens to direct encoding" do
        text = "The quick brown fox jumps over the lazy dog. " * 2000
        expect(text.size).to be > chunk_size

        direct_tokens = tokenizer_class.tokenizer.encode(text)
        chunked_tokens = tokenizer_class.encode(text)

        expect(chunked_tokens).to eq(direct_tokens)
      end

      it "works with tokenize" do
        text = "word " * 20_000
        expect(text.size).to be > chunk_size

        tokens = tokenizer_class.tokenize(text)
        expect(tokens).to be_an(Array)
        expect(tokens.length).to be > 0
      end

      it "works with size" do
        text = "word " * 20_000
        expect(text.size).to be > chunk_size

        direct_size = tokenizer_class.tokenizer.encode(text).length
        expect(tokenizer_class.size(text)).to eq(direct_size)
      end
    end

    describe "large text without whitespace" do
      it "encodes repeated characters without crashing" do
        text = "M" * (chunk_size + 1000)

        tokens = tokenizer_class.encode(text)
        expect(tokens).to be_an(Array)
        expect(tokens.length).to be > 0
      end

      it "encodes long non-whitespace runs without crashing" do
        text = ("a".."z").to_a.join * 3000
        expect(text.size).to be > chunk_size

        tokens = tokenizer_class.encode(text)
        expect(tokens).to be_an(Array)
        expect(tokens.length).to be > 0
      end
    end

    describe "chunking splits at whitespace boundaries" do
      it "splits at the last whitespace before chunk boundary" do
        before_boundary = "a" * (chunk_size - 10)
        after_boundary = "b" * 100
        text = "#{before_boundary} #{after_boundary}"

        direct_tokens =
          tokenizer_class.tokenizer.encode(before_boundary) +
            tokenizer_class.tokenizer.encode(" #{after_boundary}")

        expect(tokenizer_class.encode(text)).to eq(direct_tokens)
      end
    end

    describe "below_limit? with large text" do
      it "returns correct result for text over chunk size" do
        text = "word " * 20_000
        expect(text.size).to be > chunk_size

        actual_token_count = tokenizer_class.tokenizer.encode(text).length
        expect(
          tokenizer_class.below_limit?(text, actual_token_count + 1)
        ).to be true
        expect(tokenizer_class.below_limit?(text, 1)).to be false
      end
    end

    describe "truncate with large text" do
      it "truncates large text correctly" do
        text = "word " * 20_000
        expect(text.size).to be > chunk_size

        result = tokenizer_class.truncate(text, 100, strict: true)
        expect(tokenizer_class.size(result)).to be <= 100
        expect(result.length).to be < text.length
      end
    end
  end

  describe DiscourseAi::Tokenizer::OpenAiTokenizer do
    include_examples "safe encoding", DiscourseAi::Tokenizer::OpenAiTokenizer
  end

  describe DiscourseAi::Tokenizer::OpenAiCl100kTokenizer do
    include_examples "safe encoding",
                     DiscourseAi::Tokenizer::OpenAiCl100kTokenizer
  end
end
