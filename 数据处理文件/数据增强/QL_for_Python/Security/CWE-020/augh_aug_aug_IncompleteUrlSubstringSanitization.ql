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

// Defines regex pattern for common top-level domains
private string getCommonTLDRegex() { result = "com|org|edu|gov|uk|net|io" }

// Checks if string literal matches URL structural patterns
predicate resemblesUrl(StringLiteral urlLiteral) {
  exists(string urlContent | urlContent = urlLiteral.getText() |
    // Matches URLs with common TLDs (case-insensitive)
    urlContent.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + getCommonTLDRegex() +
        ")(:[0-9]+)?/?")
    or
    // Matches HTTP/HTTPS URLs with any TLD
    urlContent.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Identifies sanitization operations with incomplete URL validation
predicate hasIncompleteUrlSanitization(Expr sanitizedExpr, StringLiteral urlLiteral) {
  resemblesUrl(urlLiteral) and
  (
    // Direct comparison operations
    sanitizedExpr.(Compare).compares(urlLiteral, any(In i), _)
    or
    // Unsafe prefix checks
    isUnsafePrefixCheck(sanitizedExpr, urlLiteral)
    or
    // Unsafe suffix checks
    isUnsafeSuffixCheck(sanitizedExpr, urlLiteral)
  )
}

// Detects unsafe prefix checks using startswith without full URL validation
predicate isUnsafePrefixCheck(Call methodCall, StringLiteral urlLiteral) {
  methodCall.getFunc().(Attribute).getName() = "startswith" and
  methodCall.getArg(0) = urlLiteral and
  // Exclude cases where full URL path is validated
  not urlLiteral.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*")
}

// Detects unsafe suffix checks using endswith without proper TLD validation
predicate isUnsafeSuffixCheck(Call methodCall, StringLiteral urlLiteral) {
  methodCall.getFunc().(Attribute).getName() = "endswith" and
  methodCall.getArg(0) = urlLiteral and
  // Exclude cases with proper domain structure
  not urlLiteral.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+")
}

// Query: Find expressions with incomplete URL substring sanitization
from Expr sanitizedExpr, StringLiteral urlLiteral
where hasIncompleteUrlSanitization(sanitizedExpr, urlLiteral)
select sanitizedExpr, "The string $@ may be at an arbitrary position in the sanitized URL.", urlLiteral,
  urlLiteral.getText()