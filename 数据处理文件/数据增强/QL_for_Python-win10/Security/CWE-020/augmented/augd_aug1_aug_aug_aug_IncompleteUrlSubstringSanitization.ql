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
private string getCommonTldPattern() { result = "com|org|edu|gov|uk|net|io" }

// Determines if a string literal exhibits URL-like characteristics
predicate exhibitsUrlFeatures(StringLiteral candidateLiteral) {
  exists(string literalContent | literalContent = candidateLiteral.getText() |
    literalContent.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + getCommonTldPattern() + ")(:[0-9]+)?/?")
    or
    literalContent.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Detects expressions performing incomplete URL substring sanitization
predicate performsIncompleteSanitization(Expr validationExpr, StringLiteral targetLiteral) {
  exhibitsUrlFeatures(targetLiteral) and
  (
    // Case 1: Direct string comparison operations
    validationExpr.(Compare).compares(targetLiteral, any(In i), _)
    or
    // Case 2: Unsafe startswith usage
    exists(Call startswithCall |
      startswithCall.getFunc().(Attribute).getName() = "startswith" and
      startswithCall.getArg(0) = targetLiteral and
      not targetLiteral.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*") and
      validationExpr = startswithCall
    )
    or
    // Case 3: Unsafe endswith usage
    exists(Call endswithCall |
      endswithCall.getFunc().(Attribute).getName() = "endswith" and
      endswithCall.getArg(0) = targetLiteral and
      not targetLiteral.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+") and
      validationExpr = endswithCall
    )
  )
}

// Find expressions exhibiting incomplete URL substring sanitization patterns
from Expr validationExpr, StringLiteral targetLiteral
where performsIncompleteSanitization(validationExpr, targetLiteral)
select validationExpr, "The string $@ may be at an arbitrary position in the sanitized URL.", targetLiteral,
  targetLiteral.getText()