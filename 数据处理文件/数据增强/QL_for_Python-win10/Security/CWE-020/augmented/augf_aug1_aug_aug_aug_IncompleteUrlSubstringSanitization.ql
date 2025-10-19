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

// Returns regex pattern for common top-level domains used in URL validation
private string getCommonTldRegex() { result = "com|org|edu|gov|uk|net|io" }

// Determines if a string literal exhibits URL-like characteristics
predicate exhibitsUrlFeatures(StringLiteral urlStrLiteral) {
  exists(string literalContent | literalContent = urlStrLiteral.getText() |
    literalContent.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + getCommonTldRegex() + ")(:[0-9]+)?/?")
    or
    literalContent.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Detects expressions performing incomplete URL substring sanitization
predicate performsIncompleteSanitization(Expr sanitizationExpr, StringLiteral urlStrLiteral) {
  exhibitsUrlFeatures(urlStrLiteral) and
  (
    // Case 1: Direct string comparison operations
    exists(Compare cmp | cmp = sanitizationExpr and cmp.compares(urlStrLiteral, any(In i), _))
    or
    // Case 2: Unsafe startswith usage
    exists(Call unsafeMethodCall |
      unsafeMethodCall = sanitizationExpr and
      unsafeMethodCall.getFunc().(Attribute).getName() = "startswith" and
      unsafeMethodCall.getArg(0) = urlStrLiteral and
      not urlStrLiteral.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*")
    )
    or
    // Case 3: Unsafe endswith usage
    exists(Call unsafeMethodCall |
      unsafeMethodCall = sanitizationExpr and
      unsafeMethodCall.getFunc().(Attribute).getName() = "endswith" and
      unsafeMethodCall.getArg(0) = urlStrLiteral and
      not urlStrLiteral.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+")
    )
  )
}

// Find expressions exhibiting incomplete URL substring sanitization patterns
from Expr sanitizationExpr, StringLiteral urlStrLiteral
where performsIncompleteSanitization(sanitizationExpr, urlStrLiteral)
select sanitizationExpr, "The string $@ may be at an arbitrary position in the sanitized URL.", urlStrLiteral,
  urlStrLiteral.getText()