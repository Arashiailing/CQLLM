/**
 * @name Incomplete URL substring sanitization
 * @description Detects security checks on URL substrings that can be bypassed by manipulating URL structure
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

// Returns regex pattern for common top-level domains used in URL validation
private string getCommonTldPattern() { result = "com|org|edu|gov|uk|net|io" }

// Determines if a string literal resembles a URL structure
predicate resemblesUrl(StringLiteral candidate) {
  exists(string content | content = candidate.getText() |
    // Matches URLs with common TLDs (with optional protocol/port)
    content.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + getCommonTldPattern() +
        ")(:[0-9]+)?/?")
    or
    // Matches HTTP/HTTPS URLs with any TLD
    content.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Identifies insufficient sanitization operations on URL-like strings
predicate hasIncompleteSanitization(Expr sanitizationOp, StringLiteral urlLiteral) {
  resemblesUrl(urlLiteral) and
  (
    // Direct comparison operations
    sanitizationOp.(Compare).compares(urlLiteral, any(In i), _)
    or
    // Unsafe prefix checks
    isUnsafeStartswithCall(sanitizationOp, urlLiteral)
    or
    // Unsafe suffix checks
    isUnsafeEndswithCall(sanitizationOp, urlLiteral)
  )
}

// Detects unsafe startswith operations that don't validate full URL structure
predicate isUnsafeStartswithCall(Call callExpr, StringLiteral urlLiteral) {
  callExpr.getFunc().(Attribute).getName() = "startswith" and
  callExpr.getArg(0) = urlLiteral and
  // Excludes patterns that validate complete URL structure
  not urlLiteral.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*")
}

// Detects unsafe endswith operations that don't validate domain structure
predicate isUnsafeEndswithCall(Call callExpr, StringLiteral urlLiteral) {
  callExpr.getFunc().(Attribute).getName() = "endswith" and
  callExpr.getArg(0) = urlLiteral and
  // Excludes patterns that validate domain hierarchy
  not urlLiteral.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+")
}

// Finds expressions performing incomplete URL substring sanitization
from Expr sanitizationOp, StringLiteral urlLiteral
where hasIncompleteSanitization(sanitizationOp, urlLiteral)
select sanitizationOp, "The string $@ may be at an arbitrary position in the sanitized URL.", urlLiteral,
  urlLiteral.getText()