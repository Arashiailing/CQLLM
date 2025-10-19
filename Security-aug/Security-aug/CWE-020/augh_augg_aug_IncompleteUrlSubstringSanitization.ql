/**
 * @name Incomplete URL substring sanitization
 * @description Security checks on URL substrings without full parsing are vulnerable to bypass techniques.
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

// Defines regex pattern for widely used top-level domains
private string commonTldPattern() { result = "com|org|edu|gov|uk|net|io" }

// Determines if a string literal resembles URL patterns
predicate isUrlLike(StringLiteral urlStr) {
  exists(string content | content = urlStr.getText() |
    // Matches URLs with common TLDs (protocol and port optional)
    content.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + commonTldPattern() +
        ")(:[0-9]+)?/?")
    or
    // Matches HTTP/HTTPS URLs with any TLD
    content.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Identifies insufficient URL sanitization operations
predicate hasPartialUrlSanitization(Expr sanExpr, StringLiteral urlStr) {
  isUrlLike(urlStr) and
  (
    // Case 1: Direct substring comparison without full validation
    exists(Compare cmp | cmp = sanExpr | cmp.compares(urlStr, any(In i), _))
    or
    // Case 2: Unsafe prefix validation
    isUnsafePrefixOperation(sanExpr, urlStr)
    or
    // Case 3: Unsafe suffix validation
    isUnsafeSuffixOperation(sanExpr, urlStr)
  )
}

// Detects incomplete startswith checks that don't validate full URL structure
predicate isUnsafePrefixOperation(Call sanCall, StringLiteral urlStr) {
  sanCall.getFunc().(Attribute).getName() = "startswith" and
  sanCall.getArg(0) = urlStr and
  // Excludes patterns containing protocol and path separator
  not urlStr.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*")
}

// Detects incomplete endswith checks that don't validate full domain hierarchy
predicate isUnsafeSuffixOperation(Call sanCall, StringLiteral urlStr) {
  sanCall.getFunc().(Attribute).getName() = "endswith" and
  sanCall.getArg(0) = urlStr and
  // Excludes patterns with complete domain structure
  not urlStr.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+")
}

// Query: Find expressions performing incomplete URL substring sanitization
from Expr sanExpr, StringLiteral urlStr
where hasPartialUrlSanitization(sanExpr, urlStr)
select sanExpr, "The string $@ may appear at any position in the sanitized URL.", urlStr,
  urlStr.getText()