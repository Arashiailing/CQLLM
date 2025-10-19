/**
 * @name Incomplete URL substring sanitization
 * @description Security checks on the substrings of an unparsed URL are often vulnerable to bypassing.
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

// Defines regex pattern for common top-level domains (TLDs)
private string getCommonTLDRegex() { result = "com|org|edu|gov|uk|net|io" }

// Determines if a string literal exhibits URL structural characteristics
predicate isUrlLike(StringLiteral urlLiteral) {
  exists(string urlContent | urlContent = urlLiteral.getText() |
    // Matches URLs with common TLDs (case-insensitive)
    urlContent.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + getCommonTLDRegex() +
        ")(:[0-9]+)?/?")
    or
    // Matches HTTP/HTTPS URLs with any TLD
    urlContent.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Identifies sanitization operations that incompletely validate URL substrings
predicate hasIncompleteSanitization(Expr sanitizeExpr, StringLiteral urlLiteral) {
  isUrlLike(urlLiteral) and
  (
    // Direct comparison operations
    sanitizeExpr.(Compare).compares(urlLiteral, any(In i), _)
    or
    // Unsafe prefix checks
    isUnsafePrefix(sanitizeExpr, urlLiteral)
    or
    // Unsafe suffix checks
    isUnsafeSuffix(sanitizeExpr, urlLiteral)
  )
}

// Detects unsafe prefix checks using startswith without full URL validation
predicate isUnsafePrefix(Call sanitizeCall, StringLiteral urlLiteral) {
  sanitizeCall.getFunc().(Attribute).getName() = "startswith" and
  sanitizeCall.getArg(0) = urlLiteral and
  // Exclude cases where full URL path is validated
  not urlLiteral.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*")
}

// Detects unsafe suffix checks using endswith without proper TLD validation
predicate isUnsafeSuffix(Call sanitizeCall, StringLiteral urlLiteral) {
  sanitizeCall.getFunc().(Attribute).getName() = "endswith" and
  sanitizeCall.getArg(0) = urlLiteral and
  // Exclude cases with proper domain structure
  not urlLiteral.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+")
}

// Query: Find expressions with incomplete URL substring sanitization
from Expr sanitizeExpr, StringLiteral urlLiteral
where hasIncompleteSanitization(sanitizeExpr, urlLiteral)
select sanitizeExpr, "The string $@ may be at an arbitrary position in the sanitized URL.", urlLiteral,
  urlLiteral.getText()