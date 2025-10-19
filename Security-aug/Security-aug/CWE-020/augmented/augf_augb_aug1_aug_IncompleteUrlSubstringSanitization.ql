/**
 * @name Incomplete URL substring sanitization
 * @description Detects security checks on URL substrings that may be bypassed due to incomplete sanitization
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
private string getCommonTldPattern() { 
  result = "com|org|edu|gov|uk|net|io" 
}

// Determines if string literal exhibits URL characteristics
predicate isUrlLikeString(StringLiteral urlStrLiteral) {
  exists(string strContent | strContent = urlStrLiteral.getText() |
    // Match URLs with optional protocol and common TLDs
    strContent.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + getCommonTldPattern() +
        ")(:[0-9]+)?/?")
    or
    // Match standard HTTP/HTTPS URLs
    strContent.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Identifies unsafe prefix validation using startswith()
predicate hasUnsafePrefixValidation(Call methodInvocation, StringLiteral prefixStrLiteral) {
  methodInvocation.getFunc().(Attribute).getName() = "startswith" and
  methodInvocation.getArg(0) = prefixStrLiteral and
  // Exclude proper protocol prefixes
  not prefixStrLiteral.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*")
}

// Identifies unsafe suffix validation using endswith()
predicate hasUnsafeSuffixValidation(Call methodInvocation, StringLiteral suffixStrLiteral) {
  methodInvocation.getFunc().(Attribute).getName() = "endswith" and
  methodInvocation.getArg(0) = suffixStrLiteral and
  // Exclude proper domain suffixes
  not suffixStrLiteral.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+")
}

// Detects incomplete sanitization operations on URL substrings
predicate exhibitsIncompleteUrlSanitization(Expr sanitizationOperation, StringLiteral urlStrLiteral) {
  isUrlLikeString(urlStrLiteral) and
  (
    // Case 1: Direct comparison operations
    sanitizationOperation.(Compare).compares(urlStrLiteral, any(In i), _)
    or
    // Case 2: Unsafe prefix validation
    hasUnsafePrefixValidation(sanitizationOperation, urlStrLiteral)
    or
    // Case 3: Unsafe suffix validation
    hasUnsafeSuffixValidation(sanitizationOperation, urlStrLiteral)
  )
}

// Find expressions performing incomplete URL substring sanitization
from Expr sanitizationOperation, StringLiteral urlStrLiteral
where exhibitsIncompleteUrlSanitization(sanitizationOperation, urlStrLiteral)
select sanitizationOperation, "The string $@ may be at an arbitrary position in the sanitized URL.", urlStrLiteral,
  urlStrLiteral.getText()