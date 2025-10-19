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
predicate isUrlLike(StringLiteral urlLiteral) {
  exists(string text | text = urlLiteral.getText() |
    text.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + commonTldPattern() + ")(:[0-9]+)?/?")
    or
    // Alternative pattern for HTTP URLs with arbitrary TLDs
    text.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Identifies inadequate sanitization operations applied to URL substrings
predicate hasInsufficientSanitization(Expr sanitizationExpr, StringLiteral urlLiteral) {
  isUrlLike(urlLiteral) and
  (
    // Case 1: Direct comparison operations
    exists(Compare comparisonOp |
      comparisonOp.compares(urlLiteral, any(In inOperator), _) and
      sanitizationExpr = comparisonOp
    )
    or
    // Case 2: Unsafe prefix validation
    exists(Call prefixCheck |
      prefixCheck.getFunc().(Attribute).getName() = "startswith" and
      prefixCheck.getArg(0) = urlLiteral and
      not urlLiteral.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*") and
      sanitizationExpr = prefixCheck
    )
    or
    // Case 3: Unsafe suffix validation
    exists(Call suffixCheck |
      suffixCheck.getFunc().(Attribute).getName() = "endswith" and
      suffixCheck.getArg(0) = urlLiteral and
      not urlLiteral.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+") and
      sanitizationExpr = suffixCheck
    )
  )
}

// Main query: Finds expressions with incomplete URL substring sanitization
from Expr sanitizationExpr, StringLiteral urlLiteral
where hasInsufficientSanitization(sanitizationExpr, urlLiteral)
select sanitizationExpr, "The string $@ may be at an arbitrary position in the sanitized URL.", urlLiteral,
  urlLiteral.getText()