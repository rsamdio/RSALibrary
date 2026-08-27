# Rule: No Long Em Dashes

## Invariant
Long em dashes (Unicode U+2014) must NEVER be used in any agent-generated content, code comments, commit messages, pull requests, documentation, or user interface copy.

## Preferred Replacements
When structuring text or separating clauses, use one of the following alternatives:
- Comma: `,`
- Colon: `:`
- Parentheses: `(text)`
- Hyphen / en dash: `-`
- Separate sentences: End the thought with a period and start a new sentence.

## Exceptions
The only exception is when preserving literal historical syntax in external source materials or code syntax that strictly requires it. For all other text, em dashes are prohibited.

## Automated Verification
Run the verification script to check for any em dash violations before committing:
```bash
ruby scripts/agent/check_invariants.rb
```
