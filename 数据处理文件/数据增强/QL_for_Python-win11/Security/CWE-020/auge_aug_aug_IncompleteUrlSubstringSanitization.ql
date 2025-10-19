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
predicate exhibitsUrlStructure(StringLiteral urlLiteral) {
  exists(string urlText | urlText = urlLiteral.getText() |
    // Matches URLs with common TLDs (case-insensitive)
    urlText.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + getCommonTLDRegex() +
        ")(:[0-9]+)?/?")
    or
    // Matches HTTP/HTTPS URLs with any TLD
    urlText.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Identifies sanitization operations that incompletely validate URL substrings
predicate hasIncompleteUrlSanitization(Expr sanitizationExpr, StringLiteral urlLiteral) {
  exhibitsUrlStructure(urlLiteral) and
  (
    // Direct comparison operations
    sanitizationExpr.(Compare).compares(urlLiteral, any(In i), _)
    or
    // Unsafe prefix checks
    isUnsafePrefixCheck(sanitizationExpr, urlLiteral)
    or
    // Unsafe suffix checks
    isUnsafeSuffixCheck(sanitizationExpr, urlLiteral)
  )
}

// Detects unsafe prefix checks using startswith without full URL validation
predicate isUnsafePrefixCheck(Call callExpr, StringLiteral urlLiteral) {
  callExpr.getFunc().(Attribute).getName() = "startswith" and
  callExpr.getArg(0) = urlLiteral and
  // Exclude cases where full URL path is validated
  not urlLiteral.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*")
}

// Detects unsafe suffix checks using endswith without proper TLD validation
predicate isUnsafeSuffixCheck(Call callExpr, StringLiteral urlLiteral) {
  callExpr.getFunc().(Attribute).getName() = "endswith" and
  callExpr.getArg(0) = urlLiteral and
  // Exclude cases with proper domain structure
  not urlLiteral.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+")
}

// Query: Find expressions with incomplete URL substring sanitization
from Expr sanitizationExpr, StringLiteral urlLiteral
where hasIncompleteUrlSanitization(sanitizationExpr, urlLiteral)
select sanitizationExpr, "The string $@ may be at an arbitrary position in the sanitized URL.", urlLiteral,
  urlLiteral.getText()