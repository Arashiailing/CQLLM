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

// Generates regex pattern for common top-level domains used in URL validation
private string getCommonTldPattern() { result = "com|org|edu|gov|uk|net|io" }

// Determines if string literal matches URL structure patterns
predicate resemblesUrl(StringLiteral urlLiteral) {
  exists(string content | content = urlLiteral.getText() |
    content.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + getCommonTldPattern() + ")(:[0-9]+)?/?")
    or
    content.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Identifies unsafe string method checks for URL validation
predicate hasUnsafeStringMethodCheck(Call callExpr, StringLiteral urlLiteral) {
  exists(string methodName | 
    methodName = callExpr.getFunc().(Attribute).getName() and
    callExpr.getArg(0) = urlLiteral and
    (
      (methodName = "startswith" and 
       not urlLiteral.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*"))
      or
      (methodName = "endswith" and 
       not urlLiteral.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+"))
    )
  )
}

// Detects incomplete sanitization operations on URL substrings
predicate hasIncompleteUrlSanitization(Expr validationExpr, StringLiteral urlLiteral) {
  resemblesUrl(urlLiteral) and
  (
    validationExpr.(Compare).compares(urlLiteral, any(In i), _)
    or
    hasUnsafeStringMethodCheck(validationExpr, urlLiteral)
  )
}

// Main query: Locate expressions with incomplete URL substring sanitization
from Expr sanitizationExpr, StringLiteral urlLiteral
where hasIncompleteUrlSanitization(sanitizationExpr, urlLiteral)
select sanitizationExpr, "The string $@ may be at an arbitrary position in the sanitized URL.", urlLiteral,
  urlLiteral.getText()