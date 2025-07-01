# frozen_string_literal: true

require "spec_helper"
require "active_support/core_ext/string/inflections"

RSpec.describe DiscourseAi::Tokenizers do
  describe "Comprehensive tokenizer coverage" do
    let(:all_tokenizer_files) do
      Dir
        .glob("lib/discourse_ai/tokenizers/*_tokenizer.rb")
        .map { |file| File.basename(file, ".rb") }
    end

    it "has corresponding classes for all tokenizer files" do
      # Since we use comprehensive shared examples, all existing tokenizer classes are automatically tested
      # This test ensures all files have corresponding classes (which would be covered by shared examples)
      all_tokenizer_files.each do |file|
        next if file == "basic_tokenizer" # Skip base class

        class_name = file.camelize
        expect(DiscourseAi::Tokenizers.const_defined?(class_name)).to be(true),
        "File #{file} exists but class #{class_name} is not defined - shared examples won't cover it"
      end
    end
  end

  describe "Integration with available_llm_tokenizers" do
    it "all available LLM tokenizers are functional" do
      available =
        DiscourseAi::Tokenizers::BasicTokenizer.available_llm_tokenizers

      available.each do |tokenizer_class|
        expect { tokenizer_class.tokenizer }.not_to raise_error
        expect { tokenizer_class.size("test sentence") }.not_to raise_error
        expect(tokenizer_class.size("test sentence")).to be > 0
      end
    end
  end

  describe "File dependency validation" do
    let(:tokenizer_classes) do
      all_tokenizer_files =
        Dir
          .glob("lib/discourse_ai/tokenizers/*_tokenizer.rb")
          .map { |file| File.basename(file, ".rb") }

      all_tokenizer_files.filter_map do |file|
        next if file == "basic_tokenizer" # Skip base class

        class_name = file.camelize
        if DiscourseAi::Tokenizers.const_defined?(class_name)
          DiscourseAi::Tokenizers.const_get(class_name)
        end
      end
    end

    it "can initialize all tokenizers (files exist)" do
      tokenizer_classes.each do |tokenizer_class|
        expect { tokenizer_class.tokenizer }.not_to raise_error
      end
    end

    it "tokenizer files are readable" do
      tokenizer_classes.each do |tokenizer_class|
        tokenizer = tokenizer_class.tokenizer
        expect(tokenizer).not_to be_nil
      end
    end
  end
end
