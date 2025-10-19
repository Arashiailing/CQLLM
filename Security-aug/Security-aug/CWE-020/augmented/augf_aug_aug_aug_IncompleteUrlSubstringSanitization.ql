/**
 * @name Incomplete URL substring sanitization
 * @description Security checks that operate on substrings of unparsed URLs are vulnerable to bypass attacks, 
 *              as they don't account for the entire URL structure
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
private string commonTldPattern() { 
  result = "com|org|edu|gov|uk|net|io" 
}

// Determines if a string literal exhibits URL-like characteristics
predicate hasUrlCharacteristics(StringLiteral urlLiteral) {
  exists(string textContent | 
    textContent = urlLiteral.getText() and
    (
      // Matches URLs with optional protocol and common TLDs
      textContent.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + commonTldPattern() + ")(:[0-9]+)?/?")
      or
      // Matches explicit HTTP/HTTPS URLs
      textContent.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
    )
  )
}

// Detects expressions performing incomplete URL substring sanitization
predicate hasIncompleteSanitization(Expr sanitizationOperation, StringLiteral urlLiteral) {
  hasUrlCharacteristics(urlLiteral) and
  (
    // Case 1: Substring containment check using 'in' operator
    exists(Compare comparisonExpr |
      comparisonExpr.compares(urlLiteral, any(In containmentOperator), _) and
      sanitizationOperation = comparisonExpr
    )
    or
    // Case 2: Unsafe startswith usage
    exists(Call methodCall |
      methodCall.getFunc().(Attribute).getName() = "startswith" and
      methodCall.getArg(0) = urlLiteral and
      not urlLiteral.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*") and
      sanitizationOperation = methodCall
    )
    or
    // Case 3: Unsafe endswith usage
    exists(Call methodCall |
      methodCall.getFunc().(Attribute).getName() = "endswith" and
      methodCall.getArg(0) = urlLiteral and
      not urlLiteral.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+") and
      sanitizationOperation = methodCall
    )
  )
}

// Find expressions exhibiting incomplete URL substring sanitization patterns
from Expr sanitizationOperation, StringLiteral urlLiteral
where hasIncompleteSanitization(sanitizationOperation, urlLiteral)
select sanitizationOperation, "The string $@ may be at an arbitrary position in the sanitized URL.", urlLiteral,
  urlLiteral.getText()