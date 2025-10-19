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

// Identifies string literals exhibiting URL-like characteristics
predicate isUrlLike(StringLiteral urlLiteral) {
  exists(string textContent | textContent = urlLiteral.getText() |
    // Match URLs with common top-level domains
    textContent.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(com|org|edu|gov|uk|net|io)(:[0-9]+)?/?")
    or
    // Alternative pattern for HTTP URLs with arbitrary TLDs
    textContent.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Detects inadequate sanitization operations applied to URL substrings
predicate hasInsufficientSanitization(Expr sanitizationOpExpr, StringLiteral urlLiteral) {
  isUrlLike(urlLiteral) and
  (
    // Case 1: Direct comparison operations
    exists(Compare cmp | 
      cmp = sanitizationOpExpr and 
      cmp.compares(urlLiteral, any(In i), _)
    )
    or
    // Case 2: Unsafe startswith operations
    exists(Call prefixCall | 
      prefixCall = sanitizationOpExpr and
      prefixCall.getFunc().(Attribute).getName() = "startswith" and
      prefixCall.getArg(0) = urlLiteral and
      not urlLiteral.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*")
    )
    or
    // Case 3: Unsafe endswith operations
    exists(Call suffixCall | 
      suffixCall = sanitizationOpExpr and
      suffixCall.getFunc().(Attribute).getName() = "endswith" and
      suffixCall.getArg(0) = urlLiteral and
      not urlLiteral.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+")
    )
  )
}

// Main query: Finds expressions with incomplete URL substring sanitization
from Expr sanitizationOpExpr, StringLiteral urlLiteral
where hasInsufficientSanitization(sanitizationOpExpr, urlLiteral)
select sanitizationOpExpr, "The string $@ may be at an arbitrary position in the sanitized URL.", urlLiteral,
  urlLiteral.getText()