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

// Helper function that generates a regex pattern for common top-level domains
private string getCommonTldRegex() { result = "com|org|edu|gov|uk|net|io" }

// Determines if a string literal exhibits URL characteristics
predicate isUrlLike(StringLiteral urlLiteral) {
  exists(string content | content = urlLiteral.getText() |
    content.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + getCommonTldRegex() +
        ")(:[0-9]+)?/?")
    or
    content.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Identifies potentially vulnerable startswith method calls for URL validation
predicate hasUnsafeStartswithValidation(Call methodCall, StringLiteral urlLiteral) {
  methodCall.getFunc().(Attribute).getName() = "startswith" and
  methodCall.getArg(0) = urlLiteral and
  not urlLiteral.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*")
}

// Identifies potentially vulnerable endswith method calls for URL validation
predicate hasUnsafeEndswithValidation(Call methodCall, StringLiteral urlLiteral) {
  methodCall.getFunc().(Attribute).getName() = "endswith" and
  methodCall.getArg(0) = urlLiteral and
  not urlLiteral.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+")
}

// Detects incomplete URL sanitization patterns that may introduce security vulnerabilities
predicate hasIncompleteUrlSanitization(Expr sanitizationExpr, StringLiteral urlLiteral) {
  isUrlLike(urlLiteral) and
  (
    sanitizationExpr.(Compare).compares(urlLiteral, any(In i), _)
    or
    hasUnsafeStartswithValidation(sanitizationExpr, urlLiteral)
    or
    hasUnsafeEndswithValidation(sanitizationExpr, urlLiteral)
  )
}

// Main query that identifies expressions with incomplete URL substring sanitization
from Expr sanitizationExpr, StringLiteral urlLiteral
where hasIncompleteUrlSanitization(sanitizationExpr, urlLiteral)
select sanitizationExpr, "The string $@ may be at an arbitrary position in the sanitized URL.", urlLiteral,
  urlLiteral.getText()