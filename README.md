# DiscourseAi::Tokenizers

A Ruby gem providing unified access to various AI model tokenizers, including both LLM (Language Model) and embedding model tokenizers.

## Features

- **Unified Interface**: Consistent API across all tokenizers
- **Multiple Model Support**: Supports tokenizers for various AI models
- **LLM Tokenizers**: Anthropic, OpenAI, Gemini, Llama3, Qwen, Mistral
- **Embedding Tokenizers**: BERT, AllMpnetBaseV2, BgeLargeEn, BgeM3, MultilingualE5Large
- **Common Operations**: tokenize, encode, decode, size calculation, truncation
- **Unicode Support**: Proper handling of emoji and multibyte characters

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'discourse_ai-tokenizers'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install discourse_ai-tokenizers
```

## Usage

### Basic Usage

```ruby
require 'discourse_ai/tokenizers'

# Get token count
DiscourseAi::Tokenizer::OpenAiTokenizer.size("Hello world!")
# => 3

# Tokenize text
DiscourseAi::Tokenizer::OpenAiTokenizer.tokenize("Hello world!")
# => [9906, 1917, 0]

# Encode text to token IDs
DiscourseAi::Tokenizer::OpenAiTokenizer.encode("Hello world!")
# => [9906, 1917, 0]

# Decode token IDs back to text
DiscourseAi::Tokenizer::OpenAiTokenizer.decode([9906, 1917, 0])
# => "Hello world!"

# Truncate text to token limit
DiscourseAi::Tokenizer::OpenAiTokenizer.truncate("This is a long sentence", 5)
# => "This is a"

# Check if text is within token limit
DiscourseAi::Tokenizer::OpenAiTokenizer.below_limit?("Short text", 10)
# => true
```

### Available Tokenizers

#### LLM Tokenizers

- `DiscourseAi::Tokenizer::AnthropicTokenizer` - Claude models
- `DiscourseAi::Tokenizer::OpenAiTokenizer` - GPT models
- `DiscourseAi::Tokenizer::GeminiTokenizer` - Google Gemini
- `DiscourseAi::Tokenizer::Llama3Tokenizer` - Meta Llama 3
- `DiscourseAi::Tokenizer::QwenTokenizer` - Alibaba Qwen
- `DiscourseAi::Tokenizer::MistralTokenizer` - Mistral models

#### Embedding Tokenizers

- `DiscourseAi::Tokenizer::BertTokenizer` - BERT-based models
- `DiscourseAi::Tokenizer::AllMpnetBaseV2Tokenizer` - sentence-transformers/all-mpnet-base-v2
- `DiscourseAi::Tokenizer::BgeLargeEnTokenizer` - BAAI/bge-large-en
- `DiscourseAi::Tokenizer::BgeM3Tokenizer` - BAAI/bge-m3
- `DiscourseAi::Tokenizer::MultilingualE5LargeTokenizer` - intfloat/multilingual-e5-large

### Getting Available LLM Tokenizers

```ruby
# Get all available LLM tokenizers dynamically
DiscourseAi::Tokenizer::BasicTokenizer.available_llm_tokenizers
# => [DiscourseAi::Tokenizer::AnthropicTokenizer, DiscourseAi::Tokenizer::OpenAiTokenizer, ...]
```

### Advanced Usage

#### Strict Mode for Truncation

```ruby
# Strict mode ensures exact token limit compliance
DiscourseAi::Tokenizer::OpenAiTokenizer.truncate("Long text here", 5, strict: true)

# Check limits with strict mode
DiscourseAi::Tokenizer::OpenAiTokenizer.below_limit?("Text", 10, strict: true)
```

#### Unicode and Emoji Support

```ruby
# Handles unicode characters properly
text = "Hello 世界 🌍 👨‍👩‍👧‍👦"
DiscourseAi::Tokenizer::OpenAiTokenizer.size(text)
# => 8

# Truncation preserves unicode integrity
truncated = DiscourseAi::Tokenizer::OpenAiTokenizer.truncate(text, 5)
# => "Hello 世界 🌍"
```

## API Reference

All tokenizers implement the following interface:

- `tokenizer` - Returns the underlying tokenizer instance
- `tokenize(text)` - Returns array of tokens (strings or token objects)
- `encode(text)` - Returns array of token IDs (integers)
- `decode(token_ids)` - Converts token IDs back to text
- `size(text)` - Returns number of tokens in text
- `truncate(text, limit, strict: false)` - Truncates text to token limit
- `below_limit?(text, limit, strict: false)` - Checks if text is within limit

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`.

## Testing

The gem includes comprehensive test suites:

```bash
# Run all tests
bundle exec rspec

# Run specific test suites
bundle exec rspec spec/discourse_ai/tokenizers/integration_spec.rb
bundle exec rspec spec/discourse_ai/tokenizers/method_consistency_spec.rb
bundle exec rspec spec/discourse_ai/tokenizers/error_handling_spec.rb
```

## Contributing

Bug reports and pull requests are welcome on GitHub. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the DiscourseAi::Tokenizer project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](CODE_OF_CONDUCT.md).
