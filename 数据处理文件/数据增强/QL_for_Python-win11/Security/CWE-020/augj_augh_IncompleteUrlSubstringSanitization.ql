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

// Provides regex pattern for common top-level domains used in URL validation
private string getCommonTldRegex() { result = "com|org|edu|gov|uk|net|io" }

// Determines if a string literal matches URL structure patterns
predicate isUrlLikeString(StringLiteral inputStr) {
  exists(string strContent | strContent = inputStr.getText() |
    // Matches URLs with common TLDs (protocol/port optional)
    strContent.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + getCommonTldRegex() +
        ")(:[0-9]+)?/?")
    or
    // Matches HTTP/HTTPS URLs with any TLD
    strContent.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Identifies insufficient sanitization operations on URL-like strings
predicate containsIncompleteSanitization(Expr sanitizationExpr, StringLiteral urlStr) {
  isUrlLikeString(urlStr) and
  (
    // Direct comparison operations
    sanitizationExpr.(Compare).compares(urlStr, any(In i), _)
    or
    // Unsafe prefix checks
    isUnsafePrefixCheck(sanitizationExpr, urlStr)
    or
    // Unsafe suffix checks
    isUnsafeSuffixCheck(sanitizationExpr, urlStr)
  )
}

// Detects unsafe startswith operations that don't validate full URL structure
predicate isUnsafePrefixCheck(Call methodCall, StringLiteral urlStr) {
  methodCall.getFunc().(Attribute).getName() = "startswith" and
  methodCall.getArg(0) = urlStr and
  // Excludes patterns validating complete URL structure
  not urlStr.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*")
}

// Detects unsafe endswith operations that don't validate domain hierarchy
predicate isUnsafeSuffixCheck(Call methodCall, StringLiteral urlStr) {
  methodCall.getFunc().(Attribute).getName() = "endswith" and
  methodCall.getArg(0) = urlStr and
  // Excludes patterns validating domain structure
  not urlStr.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+")
}

// Locates expressions performing incomplete URL substring sanitization
from Expr sanitizationExpr, StringLiteral urlStr
where containsIncompleteSanitization(sanitizationExpr, urlStr)
select sanitizationExpr, "The string $@ may be at an arbitrary position in the sanitized URL.", urlStr,
  urlStr.getText()