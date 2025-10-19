/**
 * @name Incomplete URL substring sanitization
 * @description Security checks on substrings of unparsed URLs are vulnerable to bypass
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/incomplete-url-substring-sanitization
 * @tags correctness
 *       security
 *       external/cwe/cwe-20
 */

import python
import semmle.python.regex

// Provides regex pattern for common top-level domains
private string getCommonTldRegex() { result = "com|org|edu|gov|uk|net|io" }

// Determines if a string literal exhibits URL characteristics
predicate resemblesUrl(StringLiteral urlStringLiteral) {
  exists(string content | content = urlStringLiteral.getText() |
    content.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + getCommonTldRegex() +
        ")(:[0-9]+)?/?")
    or
    content.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Identifies unsafe startswith method calls for URL validation
predicate isUnsafeStartswithCall(Call methodCall, StringLiteral urlStringLiteral) {
  methodCall.getFunc().(Attribute).getName() = "startswith" and
  methodCall.getArg(0) = urlStringLiteral and
  not urlStringLiteral.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*")
}

// Identifies unsafe endswith method calls for URL validation
predicate isUnsafeEndswithCall(Call methodCall, StringLiteral urlStringLiteral) {
  methodCall.getFunc().(Attribute).getName() = "endswith" and
  methodCall.getArg(0) = urlStringLiteral and
  not urlStringLiteral.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+")
}

// Detects incomplete sanitization operations on URL substrings
predicate hasIncompleteUrlSanitization(Expr sanitizationOperation, StringLiteral urlStringLiteral) {
  resemblesUrl(urlStringLiteral) and
  (
    sanitizationOperation.(Compare).compares(urlStringLiteral, any(In i), _)
    or
    isUnsafeStartswithCall(sanitizationOperation, urlStringLiteral)
    or
    isUnsafeEndswithCall(sanitizationOperation, urlStringLiteral)
  )
}

// Find expressions with incomplete URL substring sanitization
from Expr sanitizationOperation, StringLiteral urlStringLiteral
where hasIncompleteUrlSanitization(sanitizationOperation, urlStringLiteral)
select sanitizationOperation, "The string $@ may be at an arbitrary position in the sanitized URL.", urlStringLiteral,
  urlStringLiteral.getText()