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

// Helper function that returns a regex pattern matching common top-level domains
private string getCommonTldPattern() { result = "com|org|edu|gov|uk|net|io" }

// Determines if a string literal has the structure of a URL
predicate resemblesUrl(StringLiteral urlStringLiteral) {
  exists(string text | text = urlStringLiteral.getText() |
    text.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + getCommonTldPattern() +
        ")(:[0-9]+)?/?")
    or
    text.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Identifies potentially insecure startswith method calls used for URL validation
predicate hasUnsafeStartswithCheck(Call callExpr, StringLiteral urlStringLiteral) {
  callExpr.getFunc().(Attribute).getName() = "startswith" and
  callExpr.getArg(0) = urlStringLiteral and
  not urlStringLiteral.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*")
}

// Identifies potentially insecure endswith method calls used for URL validation
predicate hasUnsafeEndswithCheck(Call callExpr, StringLiteral urlStringLiteral) {
  callExpr.getFunc().(Attribute).getName() = "endswith" and
  callExpr.getArg(0) = urlStringLiteral and
  not urlStringLiteral.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+")
}

// Detects URL sanitization operations that are incomplete and potentially vulnerable
predicate hasIncompleteUrlSanitization(Expr sanitizationOperation, StringLiteral urlStringLiteral) {
  resemblesUrl(urlStringLiteral) and
  (
    sanitizationOperation.(Compare).compares(urlStringLiteral, any(In i), _)
    or
    hasUnsafeStartswithCheck(sanitizationOperation, urlStringLiteral)
    or
    hasUnsafeEndswithCheck(sanitizationOperation, urlStringLiteral)
  )
}

// Main query to identify expressions with incomplete URL substring sanitization
from Expr sanitizationOperation, StringLiteral urlStringLiteral
where hasIncompleteUrlSanitization(sanitizationOperation, urlStringLiteral)
select sanitizationOperation, "The string $@ may be at an arbitrary position in the sanitized URL.", urlStringLiteral,
  urlStringLiteral.getText()