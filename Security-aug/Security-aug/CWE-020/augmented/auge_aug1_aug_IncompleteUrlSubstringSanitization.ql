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

// Defines regex pattern for commonly used top-level domains (TLDs)
private string getCommonTldPattern() { 
  result = "com|org|edu|gov|uk|net|io" 
}

// Determines if a string literal exhibits URL-like characteristics
predicate resemblesUrl(StringLiteral urlLiteral) {
  exists(string content | content = urlLiteral.getText() |
    content.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + getCommonTldPattern() +
        ")(:[0-9]+)?/?")
    or
    content.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Identifies unsafe prefix validation using startswith() method
predicate hasUnsafePrefixCheck(Call methodCall, StringLiteral prefixLiteral) {
  methodCall.getFunc().(Attribute).getName() = "startswith" and
  methodCall.getArg(0) = prefixLiteral and
  not prefixLiteral.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*")
}

// Identifies unsafe suffix validation using endswith() method
predicate hasUnsafeSuffixCheck(Call methodCall, StringLiteral suffixLiteral) {
  methodCall.getFunc().(Attribute).getName() = "endswith" and
  methodCall.getArg(0) = suffixLiteral and
  not suffixLiteral.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+")
}

// Detects incomplete sanitization operations on URL substrings
predicate hasIncompleteSanitization(Expr validationExpr, StringLiteral urlLiteral) {
  resemblesUrl(urlLiteral) and
  (
    validationExpr.(Compare).compares(urlLiteral, any(In i), _)
    or
    hasUnsafePrefixCheck(validationExpr, urlLiteral)
    or
    hasUnsafeSuffixCheck(validationExpr, urlLiteral)
  )
}

// Find expressions performing incomplete URL substring sanitization
from Expr validationExpr, StringLiteral urlLiteral
where hasIncompleteSanitization(validationExpr, urlLiteral)
select validationExpr, "The string $@ may be at an arbitrary position in the sanitized URL.", urlLiteral,
  urlLiteral.getText()