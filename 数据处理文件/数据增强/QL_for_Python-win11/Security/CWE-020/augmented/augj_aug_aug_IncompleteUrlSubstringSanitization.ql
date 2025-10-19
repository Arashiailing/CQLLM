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

// Helper function providing regex pattern for common top-level domains
private string getTldPattern() { result = "com|org|edu|gov|uk|net|io" }

// Determines if a string literal exhibits URL-like characteristics
predicate isUrlLike(StringLiteral urlLiteral) {
  exists(string urlText | urlText = urlLiteral.getText() |
    urlText.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + getTldPattern() +
        ")(:[0-9]+)?/?")
    or
    urlText.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Detects insecure startswith method calls for URL validation
predicate containsUnsafeStartswith(Call methodCall, StringLiteral urlLiteral) {
  methodCall.getFunc().(Attribute).getName() = "startswith" and
  methodCall.getArg(0) = urlLiteral and
  not urlLiteral.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*")
}

// Detects insecure endswith method calls for URL validation
predicate containsUnsafeEndswith(Call methodCall, StringLiteral urlLiteral) {
  methodCall.getFunc().(Attribute).getName() = "endswith" and
  methodCall.getArg(0) = urlLiteral and
  not urlLiteral.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+")
}

// Identifies incomplete URL sanitization operations with potential vulnerabilities
predicate hasIncompleteUrlSanitization(Expr sanitExpr, StringLiteral urlLiteral) {
  isUrlLike(urlLiteral) and
  (
    sanitExpr.(Compare).compares(urlLiteral, any(In i), _)
    or
    containsUnsafeStartswith(sanitExpr, urlLiteral)
    or
    containsUnsafeEndswith(sanitExpr, urlLiteral)
  )
}

// Main query detecting expressions with incomplete URL substring sanitization
from Expr sanitExpr, StringLiteral urlLiteral
where hasIncompleteUrlSanitization(sanitExpr, urlLiteral)
select sanitExpr, "The string $@ may be at an arbitrary position in the sanitized URL.", urlLiteral,
  urlLiteral.getText()