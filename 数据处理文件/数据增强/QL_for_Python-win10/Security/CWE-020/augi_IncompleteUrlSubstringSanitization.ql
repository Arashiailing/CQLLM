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

// Private helper returning regex pattern for common top-level domains
private string commonTopLevelDomainRegex() { result = "com|org|edu|gov|uk|net|io" }

// Determines if a string literal resembles a URL structure
predicate looksLikeUrl(StringLiteral urlLiteral) {
  exists(string literalText | literalText = urlLiteral.getText() |
    literalText.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + commonTopLevelDomainRegex() +
        ")(:[0-9]+)?/?")
    or
    // Alternative pattern for HTTP URLs with any TLD
    literalText.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Identifies incomplete sanitization operations on URL substrings
predicate incomplete_sanitization(Expr sanitizingExpr, StringLiteral urlLiteral) {
  looksLikeUrl(urlLiteral) and
  (
    sanitizingExpr.(Compare).compares(urlLiteral, any(In i), _)
    or
    unsafe_startswith_operation(sanitizingExpr, urlLiteral)
    or
    unsafe_endswith_operation(sanitizingExpr, urlLiteral)
  )
}

// Detects unsafe startswith operations on URL strings
predicate unsafe_startswith_operation(Call callNode, StringLiteral urlLiteral) {
  callNode.getFunc().(Attribute).getName() = "startswith" and
  callNode.getArg(0) = urlLiteral and
  not urlLiteral.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*")
}

// Detects unsafe endswith operations on URL strings
predicate unsafe_endswith_operation(Call callNode, StringLiteral urlLiteral) {
  callNode.getFunc().(Attribute).getName() = "endswith" and
  callNode.getArg(0) = urlLiteral and
  not urlLiteral.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+")
}

// Query: Find expressions performing incomplete URL substring sanitization
from Expr sanitizingExpr, StringLiteral urlLiteral
where incomplete_sanitization(sanitizingExpr, urlLiteral)
select sanitizingExpr, "The string $@ may be at an arbitrary position in the sanitized URL.", urlLiteral,
  urlLiteral.getText()