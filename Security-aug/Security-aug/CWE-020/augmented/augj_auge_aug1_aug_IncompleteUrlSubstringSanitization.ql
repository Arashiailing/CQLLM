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
predicate resemblesUrl(StringLiteral urlStr) {
  exists(string strContent | strContent = urlStr.getText() |
    strContent.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + getCommonTldPattern() +
        ")(:[0-9]+)?/?")
    or
    strContent.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Identifies unsafe prefix validation using startswith() method
predicate hasUnsafePrefixCheck(Call methodInvocation, StringLiteral prefixStr) {
  methodInvocation.getFunc().(Attribute).getName() = "startswith" and
  methodInvocation.getArg(0) = prefixStr and
  not prefixStr.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*")
}

// Identifies unsafe suffix validation using endswith() method
predicate hasUnsafeSuffixCheck(Call methodInvocation, StringLiteral suffixStr) {
  methodInvocation.getFunc().(Attribute).getName() = "endswith" and
  methodInvocation.getArg(0) = suffixStr and
  not suffixStr.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+")
}

// Find expressions performing incomplete URL substring sanitization
from Expr validationOp, StringLiteral urlStr
where 
  resemblesUrl(urlStr) and
  (
    validationOp.(Compare).compares(urlStr, any(In i), _)
    or
    hasUnsafePrefixCheck(validationOp, urlStr)
    or
    hasUnsafeSuffixCheck(validationOp, urlStr)
  )
select validationOp, "The string $@ may be at an arbitrary position in the sanitized URL.", urlStr,
  urlStr.getText()