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

// Returns regex pattern for common top-level domains
private string commonTopLevelDomainRegex() { result = "com|org|edu|gov|uk|net|io" }

// Determines if a string literal resembles a URL
predicate looksLikeUrl(StringLiteral urlLiteral) {
  exists(string text | text = urlLiteral.getText() |
    text.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + commonTopLevelDomainRegex() +
        ")(:[0-9]+)?/?")
    or
    text.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Identifies unsafe startswith calls for URL validation
predicate unsafeStartswithCall(Call callExpr, StringLiteral urlLiteral) {
  callExpr.getFunc().(Attribute).getName() = "startswith" and
  callExpr.getArg(0) = urlLiteral and
  not urlLiteral.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*")
}

// Identifies unsafe endswith calls for URL validation
predicate unsafeEndswithCall(Call callExpr, StringLiteral urlLiteral) {
  callExpr.getFunc().(Attribute).getName() = "endswith" and
  callExpr.getArg(0) = urlLiteral and
  not urlLiteral.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+")
}

// Detects incomplete URL substring sanitization operations
predicate incompleteSanitization(Expr sanitizationExpr, StringLiteral urlLiteral) {
  looksLikeUrl(urlLiteral) and
  (
    sanitizationExpr.(Compare).compares(urlLiteral, any(In i), _)
    or
    unsafeStartswithCall(sanitizationExpr, urlLiteral)
    or
    unsafeEndswithCall(sanitizationExpr, urlLiteral)
  )
}

// Find expressions with incomplete URL substring sanitization
from Expr sanitizationExpr, StringLiteral urlLiteral
where incompleteSanitization(sanitizationExpr, urlLiteral)
select sanitizationExpr, "The string $@ may be at an arbitrary position in the sanitized URL.", urlLiteral,
  urlLiteral.getText()