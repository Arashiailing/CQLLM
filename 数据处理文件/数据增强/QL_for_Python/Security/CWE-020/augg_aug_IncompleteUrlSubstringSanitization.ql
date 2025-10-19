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

// Defines regex pattern for common top-level domains
private string commonTldPattern() { result = "com|org|edu|gov|uk|net|io" }

// Checks if a string literal matches URL structure patterns
predicate isUrlLike(StringLiteral urlLiteral) {
  exists(string urlContent | urlContent = urlLiteral.getText() |
    // Matches URLs with common TLDs (with optional protocol and port)
    urlContent.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + commonTldPattern() +
        ")(:[0-9]+)?/?")
    or
    // Matches HTTP/HTTPS URLs with any TLD
    urlContent.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Identifies sanitization operations that don't fully validate URL structure
predicate hasPartialUrlSanitization(Expr sanitizationExpr, StringLiteral urlLiteral) {
  isUrlLike(urlLiteral) and
  (
    // Direct substring comparison without full validation
    sanitizationExpr.(Compare).compares(urlLiteral, any(In i), _)
    or
    // Unsafe prefix checks
    isUnsafePrefixOperation(sanitizationExpr, urlLiteral)
    or
    // Unsafe suffix checks
    isUnsafeSuffixOperation(sanitizationExpr, urlLiteral)
  )
}

// Detects unsafe startswith operations that don't validate full URL structure
predicate isUnsafePrefixOperation(Call sanitizationCall, StringLiteral urlLiteral) {
  sanitizationCall.getFunc().(Attribute).getName() = "startswith" and
  sanitizationCall.getArg(0) = urlLiteral and
  // Excludes patterns that include protocol and path separator
  not urlLiteral.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*")
}

// Detects unsafe endswith operations that don't validate full domain structure
predicate isUnsafeSuffixOperation(Call sanitizationCall, StringLiteral urlLiteral) {
  sanitizationCall.getFunc().(Attribute).getName() = "endswith" and
  sanitizationCall.getArg(0) = urlLiteral and
  // Excludes patterns with complete domain hierarchy
  not urlLiteral.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+")
}

// Query: Find expressions with incomplete URL substring sanitization
from Expr sanitizationExpr, StringLiteral urlLiteral
where hasPartialUrlSanitization(sanitizationExpr, urlLiteral)
select sanitizationExpr, "The string $@ may be at an arbitrary position in the sanitized URL.", urlLiteral,
  urlLiteral.getText()