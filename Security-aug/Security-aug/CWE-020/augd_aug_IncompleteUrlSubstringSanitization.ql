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
private string getCommonTLDRegex() { result = "com|org|edu|gov|uk|net|io" }

// Checks if string literal matches URL structure patterns
predicate resemblesUrl(StringLiteral urlStringLiteral) {
  exists(string content | content = urlStringLiteral.getText() |
    // Matches URLs with common TLDs
    content.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + getCommonTLDRegex() +
        ")(:[0-9]+)?/?")
    or
    // Matches HTTP URLs with any TLD
    content.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Identifies expressions performing incomplete URL sanitization
predicate hasIncompleteUrlSanitization(Expr sanitizationExpr, StringLiteral urlStringLiteral) {
  resemblesUrl(urlStringLiteral) and
  (
    // Detects comparison operations
    sanitizationExpr.(Compare).compares(urlStringLiteral, any(In i), _)
    or
    // Detects unsafe prefix checks
    isUnsafePrefixCheck(sanitizationExpr, urlStringLiteral)
    or
    // Detects unsafe suffix checks
    isUnsafeSuffixCheck(sanitizationExpr, urlStringLiteral)
  )
}

// Detects unsafe startswith operations on URL strings
predicate isUnsafePrefixCheck(Call sanitizationExpr, StringLiteral urlStringLiteral) {
  sanitizationExpr.getFunc().(Attribute).getName() = "startswith" and
  sanitizationExpr.getArg(0) = urlStringLiteral and
  // Excludes properly formatted URLs with protocol
  not urlStringLiteral.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*")
}

// Detects unsafe endswith operations on URL strings
predicate isUnsafeSuffixCheck(Call sanitizationExpr, StringLiteral urlStringLiteral) {
  sanitizationExpr.getFunc().(Attribute).getName() = "endswith" and
  sanitizationExpr.getArg(0) = urlStringLiteral and
  // Excludes properly formatted domain endings
  not urlStringLiteral.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+")
}

// Main query: Find expressions with incomplete URL substring sanitization
from Expr sanitizationExpr, StringLiteral urlStringLiteral
where hasIncompleteUrlSanitization(sanitizationExpr, urlStringLiteral)
select sanitizationExpr, "The string $@ may be at an arbitrary position in the sanitized URL.", urlStringLiteral,
  urlStringLiteral.getText()