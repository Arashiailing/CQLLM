/**
 * @name Incomplete URL substring sanitization
 * @description Security checks on URL substrings without proper parsing are vulnerable to bypass techniques.
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

// Provides regex pattern for common top-level domains used in URL validation
private string getCommonTldPattern() { result = "com|org|edu|gov|uk|net|io" }

// Determines if a string literal resembles URL structure patterns
predicate isUrlLikeLiteral(StringLiteral urlStrLiteral) {
  exists(string content | content = urlStrLiteral.getText() |
    // Match URLs with common TLDs
    content.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + getCommonTldPattern() +
        ")(:[0-9]+)?/?")
    or
    // Match HTTP/HTTPS URLs with any TLD
    content.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Identifies sanitization operations that fail to validate full URL structure
predicate hasIncompleteUrlSanitization(Expr sanitizationExpr, StringLiteral urlStrLiteral) {
  isUrlLikeLiteral(urlStrLiteral) and
  (
    // Direct comparison operations
    sanitizationExpr.(Compare).compares(urlStrLiteral, any(In i), _)
    or
    // Unsafe prefix validation
    isUnsafePrefixCheck(sanitizationExpr, urlStrLiteral)
    or
    // Unsafe suffix validation
    isUnsafeSuffixCheck(sanitizationExpr, urlStrLiteral)
  )
}

// Detects startswith calls that lack complete URL structure validation
predicate isUnsafePrefixCheck(Call methodInvocation, StringLiteral urlStrLiteral) {
  methodInvocation.getFunc().(Attribute).getName() = "startswith" and
  methodInvocation.getArg(0) = urlStrLiteral and
  not urlStrLiteral.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*")
}

// Detects endswith calls that fail to validate domain hierarchy
predicate isUnsafeSuffixCheck(Call methodInvocation, StringLiteral urlStrLiteral) {
  methodInvocation.getFunc().(Attribute).getName() = "endswith" and
  methodInvocation.getArg(0) = urlStrLiteral and
  not urlStrLiteral.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+")
}

// Main query: Locates expressions performing incomplete URL substring sanitization
from Expr sanitizationExpr, StringLiteral urlStrLiteral
where hasIncompleteUrlSanitization(sanitizationExpr, urlStrLiteral)
select sanitizationExpr, "The string $@ may be at an arbitrary position in the sanitized URL.", urlStrLiteral,
  urlStrLiteral.getText()