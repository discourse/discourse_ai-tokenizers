# frozen_string_literal: true

require "tokenizers"
require "tiktoken_ruby"
require_relative "tokenizers/version"

require_relative "tokenizer/basic_tokenizer"
require_relative "tokenizer/bert_tokenizer"
require_relative "tokenizer/anthropic_tokenizer"
require_relative "tokenizer/open_ai_tokenizer"
require_relative "tokenizer/open_ai_cl100k_tokenizer"
require_relative "tokenizer/all_mpnet_base_v2_tokenizer"
require_relative "tokenizer/multilingual_e5_large_tokenizer"
require_relative "tokenizer/bge_large_en_tokenizer"
require_relative "tokenizer/bge_m3_tokenizer"
require_relative "tokenizer/llama3_tokenizer"
require_relative "tokenizer/gemini_tokenizer"
require_relative "tokenizer/qwen_tokenizer"
require_relative "tokenizer/mistral_tokenizer"

module DiscourseAi
  module Tokenizers
    class Error < StandardError
    end

    def self.gem_root
      @gem_root ||= File.expand_path("../../..", __FILE__)
    end

    def self.vendor_path(filename)
      File.join(gem_root, "vendor", filename)
    end
  end
end
