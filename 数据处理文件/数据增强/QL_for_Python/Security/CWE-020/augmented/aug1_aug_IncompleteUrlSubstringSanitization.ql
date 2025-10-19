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

// Generates regex pattern for common top-level domains (TLDs)
private string getCommonTldPattern() { 
  result = "com|org|edu|gov|uk|net|io" 
}

// Determines if a string literal exhibits URL-like characteristics
predicate resemblesUrl(StringLiteral urlStr) {
  exists(string text | text = urlStr.getText() |
    text.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + getCommonTldPattern() +
        ")(:[0-9]+)?/?")
    or
    text.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Identifies unsafe prefix validation using startswith()
predicate hasUnsafePrefixCheck(Call callExpr, StringLiteral prefixStr) {
  callExpr.getFunc().(Attribute).getName() = "startswith" and
  callExpr.getArg(0) = prefixStr and
  not prefixStr.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*")
}

// Identifies unsafe suffix validation using endswith()
predicate hasUnsafeSuffixCheck(Call callExpr, StringLiteral suffixStr) {
  callExpr.getFunc().(Attribute).getName() = "endswith" and
  callExpr.getArg(0) = suffixStr and
  not suffixStr.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+")
}

// Detects incomplete sanitization operations on URL substrings
predicate hasIncompleteSanitization(Expr validationExpr, StringLiteral urlStr) {
  resemblesUrl(urlStr) and
  (
    validationExpr.(Compare).compares(urlStr, any(In i), _)
    or
    hasUnsafePrefixCheck(validationExpr, urlStr)
    or
    hasUnsafeSuffixCheck(validationExpr, urlStr)
  )
}

// Find expressions performing incomplete URL substring sanitization
from Expr validationExpr, StringLiteral urlStr
where hasIncompleteSanitization(validationExpr, urlStr)
select validationExpr, "The string $@ may be at an arbitrary position in the sanitized URL.", urlStr,
  urlStr.getText()