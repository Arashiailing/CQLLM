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

// Defines regex pattern for common top-level domains used in URL validation
private string commonTldPattern() { result = "com|org|edu|gov|uk|net|io" }

// Checks if a string literal matches URL structure patterns
predicate isUrlLikeLiteral(StringLiteral targetLiteral) {
  exists(string urlContent | urlContent = targetLiteral.getText() |
    // Match URLs with common TLDs
    urlContent.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + commonTldPattern() +
        ")(:[0-9]+)?/?")
    or
    // Match HTTP/HTTPS URLs with any TLD
    urlContent.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Identifies sanitization operations that don't validate full URL structure
predicate hasIncompleteUrlSanitization(Expr sanitizerOp, StringLiteral urlLiteral) {
  isUrlLikeLiteral(urlLiteral) and
  (
    // Direct comparison operations
    sanitizerOp.(Compare).compares(urlLiteral, any(In i), _)
    or
    // Unsafe prefix validation
    isUnsafePrefixCheck(sanitizerOp, urlLiteral)
    or
    // Unsafe suffix validation
    isUnsafeSuffixCheck(sanitizerOp, urlLiteral)
  )
}

// Detects startswith calls that don't validate complete URL structure
predicate isUnsafePrefixCheck(Call methodCall, StringLiteral urlLiteral) {
  methodCall.getFunc().(Attribute).getName() = "startswith" and
  methodCall.getArg(0) = urlLiteral and
  not urlLiteral.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*")
}

// Detects endswith calls that don't validate domain hierarchy
predicate isUnsafeSuffixCheck(Call methodCall, StringLiteral urlLiteral) {
  methodCall.getFunc().(Attribute).getName() = "endswith" and
  methodCall.getArg(0) = urlLiteral and
  not urlLiteral.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+")
}

// Main query: Find expressions performing incomplete URL substring sanitization
from Expr sanitizerExpr, StringLiteral targetUrl
where hasIncompleteUrlSanitization(sanitizerExpr, targetUrl)
select sanitizerExpr, "The string $@ may be at an arbitrary position in the sanitized URL.", targetUrl,
  targetUrl.getText()