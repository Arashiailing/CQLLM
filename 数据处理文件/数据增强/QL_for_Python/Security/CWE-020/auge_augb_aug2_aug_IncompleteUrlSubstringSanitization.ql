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

// Generates regex pattern for widely used top-level domains
private string commonTldPattern() { result = "com|org|edu|gov|uk|net|io" }

// Determines if a string literal exhibits URL-like characteristics
predicate isUrlLike(StringLiteral urlStrLiteral) {
  exists(string strValue | strValue = urlStrLiteral.getText() |
    // Match URLs with common TLDs
    strValue.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + commonTldPattern() +
        ")(:[0-9]+)?/?")
    or
    // Alternative pattern for HTTP URLs with arbitrary TLDs
    strValue.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Identifies inadequate sanitization operations applied to URL substrings
predicate hasInsufficientSanitization(Expr sanitizationExpr, StringLiteral urlStrLiteral) {
  isUrlLike(urlStrLiteral) and
  (
    // Case 1: Direct comparison operations
    sanitizationExpr.(Compare).compares(urlStrLiteral, any(In i), _)
    or
    // Case 2: Unsafe startswith operations
    exists(Call prefixCall |
      prefixCall.getFunc().(Attribute).getName() = "startswith" and
      prefixCall.getArg(0) = urlStrLiteral and
      not urlStrLiteral.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*") and
      sanitizationExpr = prefixCall
    )
    or
    // Case 3: Unsafe endswith operations
    exists(Call suffixCall |
      suffixCall.getFunc().(Attribute).getName() = "endswith" and
      suffixCall.getArg(0) = urlStrLiteral and
      not urlStrLiteral.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+") and
      sanitizationExpr = suffixCall
    )
  )
}

// Main query: Finds expressions with incomplete URL substring sanitization
from Expr sanitizationExpr, StringLiteral urlStrLiteral
where hasInsufficientSanitization(sanitizationExpr, urlStrLiteral)
select sanitizationExpr, "The string $@ may be at an arbitrary position in the sanitized URL.", urlStrLiteral,
  urlStrLiteral.getText()