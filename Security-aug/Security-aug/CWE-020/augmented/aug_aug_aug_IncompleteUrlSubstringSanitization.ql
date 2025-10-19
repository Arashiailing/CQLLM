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
private string commonTldPattern() { result = "com|org|edu|gov|uk|net|io" }

// Determines if a string literal exhibits URL-like characteristics
predicate hasUrlCharacteristics(StringLiteral urlStrLiteral) {
  exists(string strContent | strContent = urlStrLiteral.getText() |
    strContent.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + commonTldPattern() + ")(:[0-9]+)?/?")
    or
    strContent.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Detects expressions performing incomplete URL substring sanitization
predicate hasIncompleteSanitization(Expr sanitizationExpr, StringLiteral urlStrLiteral) {
  hasUrlCharacteristics(urlStrLiteral) and
  (
    sanitizationExpr.(Compare).compares(urlStrLiteral, any(In i), _)
    or
    // Unsafe startswith usage
    exists(Call methodInvocation |
      methodInvocation.getFunc().(Attribute).getName() = "startswith" and
      methodInvocation.getArg(0) = urlStrLiteral and
      not urlStrLiteral.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*") and
      sanitizationExpr = methodInvocation
    )
    or
    // Unsafe endswith usage
    exists(Call methodInvocation |
      methodInvocation.getFunc().(Attribute).getName() = "endswith" and
      methodInvocation.getArg(0) = urlStrLiteral and
      not urlStrLiteral.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+") and
      sanitizationExpr = methodInvocation
    )
  )
}

// Find expressions exhibiting incomplete URL substring sanitization patterns
from Expr sanitizationExpr, StringLiteral urlStrLiteral
where hasIncompleteSanitization(sanitizationExpr, urlStrLiteral)
select sanitizationExpr, "The string $@ may be at an arbitrary position in the sanitized URL.", urlStrLiteral,
  urlStrLiteral.getText()