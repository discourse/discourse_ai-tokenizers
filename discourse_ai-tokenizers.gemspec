# frozen_string_literal: true

require_relative "lib/discourse_ai/tokenizers/version"

Gem::Specification.new do |spec|
  spec.name = "discourse_ai-tokenizers"
  spec.version = DiscourseAi::Tokenizers::VERSION
  spec.authors = ["Rafael Silva"]
  spec.email = ["xfalcox@gmail.com"]

  spec.summary = "Unified tokenizer interface for AI/ML models supporting OpenAI, Anthropic, Gemini, Llama, and embedding models"
  spec.description = "A Ruby gem providing a consistent interface for various AI/ML tokenizers including OpenAI GPT, Anthropic Claude, Google Gemini, Meta Llama, Mistral, Qwen, and embedding models like BERT, BGE, and multilingual-E5. Features caching, truncation, token counting, and error handling across different tokenization libraries."
  spec.homepage = "https://github.com/discourse/discourse_ai-tokenizers"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/discourse/discourse_ai-tokenizers/blob/main/CHANGELOG.md"

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = %w[lib vendor]

  spec.add_dependency "activesupport", ">= 6.0"
  spec.add_dependency "tiktoken_ruby", "~> 0.0.11.1"
  spec.add_dependency "tokenizers", "~> 0.5.4"

  spec.add_development_dependency "rubocop-discourse", "= 3.8.1"
  spec.add_development_dependency "syntax_tree", "~> 6.2.0"
end
