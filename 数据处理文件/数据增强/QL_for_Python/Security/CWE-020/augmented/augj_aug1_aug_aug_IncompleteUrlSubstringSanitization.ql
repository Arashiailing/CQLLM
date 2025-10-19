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

// Generates regex pattern for common top-level domains
private string getCommonTldPattern() { result = "com|org|edu|gov|uk|net|io" }

// Checks if string literal resembles a URL structure
predicate resemblesUrl(StringLiteral urlLiteral) {
  exists(string urlText | urlText = urlLiteral.getText() |
    urlText.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + getCommonTldPattern() +
        ")(:[0-9]+)?/?")
    or
    urlText.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Detects unsafe startswith checks on URL substrings
predicate hasUnsafeStartswithCheck(Call methodInvocation, StringLiteral urlLiteral) {
  methodInvocation.getFunc().(Attribute).getName() = "startswith" and
  methodInvocation.getArg(0) = urlLiteral and
  not urlLiteral.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*")
}

// Detects unsafe endswith checks on URL substrings
predicate hasUnsafeEndswithCheck(Call methodInvocation, StringLiteral urlLiteral) {
  methodInvocation.getFunc().(Attribute).getName() = "endswith" and
  methodInvocation.getArg(0) = urlLiteral and
  not urlLiteral.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+")
}

// Identifies expressions with incomplete URL sanitization
predicate hasIncompleteUrlSanitization(Expr sanitizationExpression, StringLiteral urlLiteral) {
  resemblesUrl(urlLiteral) and
  (
    sanitizationExpression.(Compare).compares(urlLiteral, any(In i), _)
    or
    hasUnsafeStartswithCheck(sanitizationExpression, urlLiteral)
    or
    hasUnsafeEndswithCheck(sanitizationExpression, urlLiteral)
  )
}

// Main query detecting vulnerable URL sanitization patterns
from Expr sanitizationExpression, StringLiteral urlLiteral
where hasIncompleteUrlSanitization(sanitizationExpression, urlLiteral)
select sanitizationExpression, "The string $@ may be at an arbitrary position in the sanitized URL.", urlLiteral,
  urlLiteral.getText()