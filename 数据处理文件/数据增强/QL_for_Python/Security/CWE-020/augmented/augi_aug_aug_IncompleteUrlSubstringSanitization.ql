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

// Returns regex pattern for common top-level domains used in URL validation
private string getCommonTldPattern() { result = "com|org|edu|gov|uk|net|io" }

// Checks if string literal has URL-like structure using domain patterns
predicate resemblesUrl(StringLiteral urlString) {
  exists(string urlText | urlText = urlString.getText() |
    // Match URLs with common TLDs (case-insensitive)
    urlText.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + getCommonTldPattern() +
        ")(:[0-9]+)?/?")
    or
    // Match standard HTTP/HTTPS URLs
    urlText.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Identifies vulnerable startswith() checks that don't validate full URL structure
predicate hasUnsafeStartswithCheck(Call methodCall, StringLiteral urlString) {
  methodCall.getFunc().(Attribute).getName() = "startswith" and
  methodCall.getArg(0) = urlString and
  // Exclude checks that validate full protocol and path
  not urlString.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*")
}

// Identifies vulnerable endswith() checks that don't validate full domain structure
predicate hasUnsafeEndswithCheck(Call methodCall, StringLiteral urlString) {
  methodCall.getFunc().(Attribute).getName() = "endswith" and
  methodCall.getArg(0) = urlString and
  // Exclude checks that validate multi-level domains
  not urlString.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+")
}

// Detects incomplete sanitization operations on URL-like strings
predicate hasIncompleteUrlSanitization(Expr sanitizationExpr, StringLiteral urlString) {
  resemblesUrl(urlString) and
  (
    // Direct string comparison operations
    sanitizationExpr.(Compare).compares(urlString, any(In i), _)
    or
    // Unsafe prefix checks
    hasUnsafeStartswithCheck(sanitizationExpr, urlString)
    or
    // Unsafe suffix checks
    hasUnsafeEndswithCheck(sanitizationExpr, urlString)
  )
}

// Main query to find expressions with incomplete URL substring sanitization
from Expr sanitizationExpr, StringLiteral urlString
where hasIncompleteUrlSanitization(sanitizationExpr, urlString)
select sanitizationExpr, "The string $@ may be at an arbitrary position in the sanitized URL.", urlString,
  urlString.getText()