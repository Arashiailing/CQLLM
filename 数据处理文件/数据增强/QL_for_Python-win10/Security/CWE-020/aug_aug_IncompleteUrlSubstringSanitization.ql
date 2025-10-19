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

// Checks if a string literal matches URL structural patterns
predicate resemblesUrl(StringLiteral urlStr) {
  exists(string urlContent | urlContent = urlStr.getText() |
    // Matches URLs with common TLDs (case-insensitive)
    urlContent.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + getCommonTLDRegex() +
        ")(:[0-9]+)?/?")
    or
    // Matches HTTP/HTTPS URLs with any TLD
    urlContent.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Identifies sanitization operations that incompletely validate URL substrings
predicate hasIncompleteUrlSanitization(Expr sanExpr, StringLiteral urlStr) {
  resemblesUrl(urlStr) and
  (
    // Direct comparison operations
    sanExpr.(Compare).compares(urlStr, any(In i), _)
    or
    // Unsafe prefix checks
    isUnsafePrefixCheck(sanExpr, urlStr)
    or
    // Unsafe suffix checks
    isUnsafeSuffixCheck(sanExpr, urlStr)
  )
}

// Detects unsafe prefix checks using startswith without full URL validation
predicate isUnsafePrefixCheck(Call sanCall, StringLiteral urlStr) {
  sanCall.getFunc().(Attribute).getName() = "startswith" and
  sanCall.getArg(0) = urlStr and
  // Exclude cases where full URL path is validated
  not urlStr.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*")
}

// Detects unsafe suffix checks using endswith without proper TLD validation
predicate isUnsafeSuffixCheck(Call sanCall, StringLiteral urlStr) {
  sanCall.getFunc().(Attribute).getName() = "endswith" and
  sanCall.getArg(0) = urlStr and
  // Exclude cases with proper domain structure
  not urlStr.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+")
}

// Query: Find expressions with incomplete URL substring sanitization
from Expr sanExpr, StringLiteral urlStr
where hasIncompleteUrlSanitization(sanExpr, urlStr)
select sanExpr, "The string $@ may be at an arbitrary position in the sanitized URL.", urlStr,
  urlStr.getText()