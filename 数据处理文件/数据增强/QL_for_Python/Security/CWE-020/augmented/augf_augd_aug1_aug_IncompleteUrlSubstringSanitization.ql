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
predicate looksLikeUrl(StringLiteral urlStr) {
  exists(string content | content = urlStr.getText() |
    // Match URLs with common TLDs or standard HTTP(S) patterns
    content.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + getCommonTldPattern() + ")(:[0-9]+)?/?")
    or
    content.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Identifies unsafe prefix validation using startswith()
predicate hasUnsafePrefixCheck(Call methodCall, StringLiteral prefixStr) {
  methodCall.getFunc().(Attribute).getName() = "startswith" and
  methodCall.getArg(0) = prefixStr and
  // Exclude proper HTTP(S) prefix patterns
  not prefixStr.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*")
}

// Identifies unsafe suffix validation using endswith()
predicate hasUnsafeSuffixCheck(Call methodCall, StringLiteral suffixStr) {
  methodCall.getFunc().(Attribute).getName() = "endswith" and
  methodCall.getArg(0) = suffixStr and
  // Exclude proper domain suffix patterns
  not suffixStr.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+")
}

// Detects incomplete sanitization operations on URL substrings
predicate exhibitsIncompleteUrlSanitization(Expr validation, StringLiteral urlStr) {
  looksLikeUrl(urlStr) and
  (
    // Direct comparison operations
    validation.(Compare).compares(urlStr, any(In i), _)
    or
    // Unsafe prefix checks
    hasUnsafePrefixCheck(validation, urlStr)
    or
    // Unsafe suffix checks
    hasUnsafeSuffixCheck(validation, urlStr)
  )
}

// Find expressions performing incomplete URL substring sanitization
from Expr validation, StringLiteral urlStr
where exhibitsIncompleteUrlSanitization(validation, urlStr)
select validation, "The string $@ may be at an arbitrary position in the sanitized URL.", urlStr,
  urlStr.getText()