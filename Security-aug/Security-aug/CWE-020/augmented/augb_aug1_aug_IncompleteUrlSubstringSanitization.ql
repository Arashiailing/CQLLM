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

// Defines regex pattern for common top-level domains
private string commonTldPattern() { 
  result = "com|org|edu|gov|uk|net|io" 
}

// Checks if string literal exhibits URL characteristics
predicate isUrlLike(StringLiteral urlLiteral) {
  exists(string content | content = urlLiteral.getText() |
    content.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + commonTldPattern() +
        ")(:[0-9]+)?/?")
    or
    content.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Identifies unsafe prefix validation using startswith()
predicate containsUnsafePrefixCheck(Call methodCall, StringLiteral prefixLiteral) {
  methodCall.getFunc().(Attribute).getName() = "startswith" and
  methodCall.getArg(0) = prefixLiteral and
  not prefixLiteral.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*")
}

// Identifies unsafe suffix validation using endswith()
predicate containsUnsafeSuffixCheck(Call methodCall, StringLiteral suffixLiteral) {
  methodCall.getFunc().(Attribute).getName() = "endswith" and
  methodCall.getArg(0) = suffixLiteral and
  not suffixLiteral.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+")
}

// Detects incomplete sanitization operations on URL substrings
predicate hasIncompleteUrlSanitization(Expr sanitizationExpr, StringLiteral urlLiteral) {
  isUrlLike(urlLiteral) and
  (
    sanitizationExpr.(Compare).compares(urlLiteral, any(In i), _)
    or
    containsUnsafePrefixCheck(sanitizationExpr, urlLiteral)
    or
    containsUnsafeSuffixCheck(sanitizationExpr, urlLiteral)
  )
}

// Find expressions performing incomplete URL substring sanitization
from Expr sanitizationExpr, StringLiteral urlLiteral
where hasIncompleteUrlSanitization(sanitizationExpr, urlLiteral)
select sanitizationExpr, "The string $@ may be at an arbitrary position in the sanitized URL.", urlLiteral,
  urlLiteral.getText()