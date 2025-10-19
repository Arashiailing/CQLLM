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
predicate hasUrlCharacteristics(StringLiteral urlLiteral) {
  exists(string urlText | urlText = urlLiteral.getText() |
    urlText.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + getCommonTldPattern() + ")(:[0-9]+)?/?")
    or
    urlText.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Detects expressions performing incomplete URL substring sanitization
predicate containsIncompleteSanitization(Expr sanitizationExpr, StringLiteral targetUrlLiteral) {
  hasUrlCharacteristics(targetUrlLiteral) and
  (
    // Case 1: Direct string comparison operations
    sanitizationExpr.(Compare).compares(targetUrlLiteral, any(In i), _)
    or
    // Case 2: Unsafe startswith usage
    exists(Call startswithMethodCall |
      startswithMethodCall.getFunc().(Attribute).getName() = "startswith" and
      startswithMethodCall.getArg(0) = targetUrlLiteral and
      not targetUrlLiteral.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*") and
      sanitizationExpr = startswithMethodCall
    )
    or
    // Case 3: Unsafe endswith usage
    exists(Call endswithMethodCall |
      endswithMethodCall.getFunc().(Attribute).getName() = "endswith" and
      endswithMethodCall.getArg(0) = targetUrlLiteral and
      not targetUrlLiteral.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+") and
      sanitizationExpr = endswithMethodCall
    )
  )
}

// Find expressions exhibiting incomplete URL substring sanitization patterns
from Expr sanitizationExpr, StringLiteral targetUrlLiteral
where containsIncompleteSanitization(sanitizationExpr, targetUrlLiteral)
select sanitizationExpr, "The string $@ may be at an arbitrary position in the sanitized URL.", targetUrlLiteral,
  targetUrlLiteral.getText()