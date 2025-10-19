/**
 * @name Incomplete URL substring sanitization
 * @description Detects security risks when URL substrings are validated without proper parsing, which can be bypassed.
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

// Returns regex pattern for common top-level domains
private string commonTldPattern() { result = "com|org|edu|gov|uk|net|io" }

// Checks if string literal has URL-like characteristics
predicate isUrlLike(StringLiteral urlStr) {
  exists(string literalContent | literalContent = urlStr.getText() |
    literalContent.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + commonTldPattern() + ")(:[0-9]+)?/?")
    or
    // Alternative pattern for HTTP URLs with arbitrary TLDs
    literalContent.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Detects insufficient sanitization of URL substrings
predicate hasInsufficientSanitization(Expr sanitizationOp, StringLiteral urlStr) {
  isUrlLike(urlStr) and
  (
    // Case 1: Direct comparison operations
    exists(Compare comparisonExpr |
      comparisonExpr.compares(urlStr, any(In inExpr), _) and
      sanitizationOp = comparisonExpr
    )
    or
    // Case 2: Unsafe prefix validation
    exists(Call prefixCall |
      prefixCall.getFunc().(Attribute).getName() = "startswith" and
      prefixCall.getArg(0) = urlStr and
      not urlStr.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*") and
      sanitizationOp = prefixCall
    )
    or
    // Case 3: Unsafe suffix validation
    exists(Call suffixCall |
      suffixCall.getFunc().(Attribute).getName() = "endswith" and
      suffixCall.getArg(0) = urlStr and
      not urlStr.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+") and
      sanitizationOp = suffixCall
    )
  )
}

// Query: Locates expressions with incomplete URL substring sanitization
from Expr sanitizationOp, StringLiteral urlStr
where hasInsufficientSanitization(sanitizationOp, urlStr)
select sanitizationOp, "The string $@ may be at an arbitrary position in the sanitized URL.", urlStr,
  urlStr.getText()