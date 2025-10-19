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

// Helper function that generates a regex pattern to match common top-level domains
private string getCommonTldRegex() { result = "com|org|edu|gov|uk|net|io" }

// URL pattern matching predicates
predicate resemblesUrl(StringLiteral urlStr) {
  exists(string urlText | urlText = urlStr.getText() |
    urlText.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + getCommonTldRegex() +
        ")(:[0-9]+)?/?")
    or
    urlText.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Unsafe method call detection predicates
predicate hasUnsafeStartswithCheck(Call methodCall, StringLiteral urlStr) {
  methodCall.getFunc().(Attribute).getName() = "startswith" and
  methodCall.getArg(0) = urlStr and
  not urlStr.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*")
}

predicate hasUnsafeEndswithCheck(Call methodCall, StringLiteral urlStr) {
  methodCall.getFunc().(Attribute).getName() = "endswith" and
  methodCall.getArg(0) = urlStr and
  not urlStr.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+")
}

// Main vulnerability detection predicate
predicate hasIncompleteUrlSanitization(Expr sanitizationExpr, StringLiteral urlStr) {
  resemblesUrl(urlStr) and
  (
    sanitizationExpr.(Compare).compares(urlStr, any(In i), _)
    or
    hasUnsafeStartswithCheck(sanitizationExpr, urlStr)
    or
    hasUnsafeEndswithCheck(sanitizationExpr, urlStr)
  )
}

// Main query to identify expressions with incomplete URL substring sanitization
from Expr sanitizationExpr, StringLiteral urlStr
where hasIncompleteUrlSanitization(sanitizationExpr, urlStr)
select sanitizationExpr, "The string $@ may be at an arbitrary position in the sanitized URL.", urlStr,
  urlStr.getText()