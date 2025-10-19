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
private string getCommonTldRegex() { result = "com|org|edu|gov|uk|net|io" }

// Determines if a string literal exhibits URL-like characteristics
predicate containsUrlPattern(StringLiteral urlStrLiteral) {
  exists(string content | content = urlStrLiteral.getText() |
    content.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + getCommonTldRegex() + ")(:[0-9]+)?/?")
    or
    content.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Detects expressions performing incomplete URL substring sanitization
predicate exhibitsIncompleteSanitization(Expr sanitizationExpr, StringLiteral urlStrLiteral) {
  containsUrlPattern(urlStrLiteral) and
  (
    // Case 1: Direct string comparison operations
    exists(Compare cmp | 
      cmp.compares(urlStrLiteral, any(In i), _) and
      sanitizationExpr = cmp
    )
    or
    // Case 2: Unsafe startswith usage
    exists(Call callExpr | 
      callExpr.getFunc().(Attribute).getName() = "startswith" and
      callExpr.getArg(0) = urlStrLiteral and
      not urlStrLiteral.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*") and
      sanitizationExpr = callExpr
    )
    or
    // Case 3: Unsafe endswith usage
    exists(Call callExpr | 
      callExpr.getFunc().(Attribute).getName() = "endswith" and
      callExpr.getArg(0) = urlStrLiteral and
      not urlStrLiteral.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+") and
      sanitizationExpr = callExpr
    )
  )
}

// Find expressions exhibiting incomplete URL substring sanitization patterns
from Expr sanitizationExpr, StringLiteral urlStrLiteral
where exhibitsIncompleteSanitization(sanitizationExpr, urlStrLiteral)
select sanitizationExpr, "The string $@ may be at an arbitrary position in the sanitized URL.", urlStrLiteral,
  urlStrLiteral.getText()