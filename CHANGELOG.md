## [0.4.2] - 2026-02-27

- Normalize `ASCII-8BIT`/non-UTF-8 string inputs before tokenization to prevent `EncodingError` in `truncate`, `encode`, and `below_limit?`

## [0.4.1] - 2026-02-26

- Fix tiktoken-rs stack overflow crash by chunking large inputs at whitespace boundaries before encoding

## [0.4.0] - 2026-01-06

- Add Ruby 4.0 compatibility

## [0.3.2] - 2025-12-10

- Fix truncation logic in OpenAiTokenizer could lead to string parsing fails

## [0.3.1] - 2025-07-07

- Refactor OpenAiO200kTokenizer class to OpenAiTokenizer as primary class name
- Update backward compatibility alias (OpenAiO200kTokenizer now aliases OpenAiTokenizer)
- Update version to 0.3.1

## [0.3.0] - 2025-07-04

- Add OpenAiCl100kTokenizer class for cl100k_base encoding
- Refactor OpenAiTokenizer to OpenAiO200kTokenizer with backward compatibility alias
- Update version to 0.3.0

## [0.2.0] - 2025-07-02

- Initial release
