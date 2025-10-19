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

// Determines if a string literal matches URL structural patterns
predicate resemblesUrl(StringLiteral urlStr) {
  exists(string textContent | textContent = urlStr.getText() |
    // Case-insensitive match for URLs with common TLDs
    textContent.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + getCommonTLDRegex() + ")(:[0-9]+)?/?")
    or
    // Case-insensitive match for HTTP/HTTPS URLs with any TLD
    textContent.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Identifies sanitization operations that incompletely validate URL substrings
predicate hasIncompleteUrlSanitization(Expr sanitizedExpr, StringLiteral urlStr) {
  resemblesUrl(urlStr) and
  (
    // Direct comparison operations
    sanitizedExpr.(Compare).compares(urlStr, any(In i), _)
    or
    // Unsafe prefix checks
    isUnsafePrefixCheck(sanitizedExpr, urlStr)
    or
    // Unsafe suffix checks
    isUnsafeSuffixCheck(sanitizedExpr, urlStr)
  )
}

// Detects unsafe prefix checks using startswith without full URL validation
predicate isUnsafePrefixCheck(Call methodCall, StringLiteral urlStr) {
  methodCall.getFunc().(Attribute).getName() = "startswith" and
  methodCall.getArg(0) = urlStr and
  // Exclude cases where full URL path is validated
  not urlStr.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*")
}

// Detects unsafe suffix checks using endswith without proper TLD validation
predicate isUnsafeSuffixCheck(Call methodCall, StringLiteral urlStr) {
  methodCall.getFunc().(Attribute).getName() = "endswith" and
  methodCall.getArg(0) = urlStr and
  // Exclude cases with proper domain structure
  not urlStr.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+")
}

// Query: Find expressions with incomplete URL substring sanitization
from Expr sanitizedExpr, StringLiteral urlStr
where hasIncompleteUrlSanitization(sanitizedExpr, urlStr)
select sanitizedExpr, "The string $@ may be at an arbitrary position in the sanitized URL.", urlStr,
  urlStr.getText()