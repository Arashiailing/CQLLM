/**
 * @name Incomplete URL substring sanitization
 * @description Detects security vulnerabilities where URL substring checks are insufficient,
 *              allowing potential bypasses of security controls.
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

// Returns regex pattern matching common top-level domains
private string getCommonTLDRegexPattern() { result = "com|org|edu|gov|uk|net|io" }

// Determines if a string literal has URL-like structure
predicate isUrlLikeString(StringLiteral urlString) {
  exists(string literalContent | literalContent = urlString.getText() |
    // Matches URLs with common TLDs
    literalContent.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + getCommonTLDRegexPattern() +
        ")(:[0-9]+)?/?")
    or
    // Matches HTTP URLs with any TLD
    literalContent.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Identifies insufficient sanitization operations on URL substrings
predicate hasInsufficientUrlSanitization(Expr sanitizationExpr, StringLiteral urlStringLiteral) {
  isUrlLikeString(urlStringLiteral) and
  (
    sanitizationExpr.(Compare).compares(urlStringLiteral, any(In i), _)
    or
    isUnsafeStringBoundaryCheck(sanitizationExpr, urlStringLiteral)
  )
}

// Detects unsafe startswith/endswith operations on URLs
predicate isUnsafeStringBoundaryCheck(Call methodCall, StringLiteral urlStringLiteral) {
  (methodCall.getFunc().(Attribute).getName() = "startswith" or
   methodCall.getFunc().(Attribute).getName() = "endswith") and
  methodCall.getArg(0) = urlStringLiteral and
  (
    // For startswith, check if it doesn't include full URL with path
    (methodCall.getFunc().(Attribute).getName() = "startswith" and
     not urlStringLiteral.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*"))
    or
    // For endswith, check if it doesn't include proper domain structure
    (methodCall.getFunc().(Attribute).getName() = "endswith" and
     not urlStringLiteral.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+"))
  )
}

// Main query: Find expressions with incomplete URL substring sanitization
from Expr sanitizationExpr, StringLiteral urlStringLiteral
where hasInsufficientUrlSanitization(sanitizationExpr, urlStringLiteral)
select sanitizationExpr, "The string $@ may be at an arbitrary position in the sanitized URL.", urlStringLiteral,
  urlStringLiteral.getText()