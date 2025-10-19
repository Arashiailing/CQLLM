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
predicate hasUrlCharacteristics(StringLiteral urlLiteral) {
  exists(string content | content = urlLiteral.getText() |
    content.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + commonTldPattern() + ")(:[0-9]+)?/?")
    or
    content.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Detects expressions performing incomplete URL substring sanitization
predicate hasIncompleteSanitization(Expr sanitizationCheck, StringLiteral urlLiteral) {
  hasUrlCharacteristics(urlLiteral) and
  (
    // Case 1: Direct string comparison operations
    sanitizationCheck.(Compare).compares(urlLiteral, any(In i), _)
    or
    // Case 2: Unsafe startswith usage
    exists(Call methodCall |
      methodCall.getFunc().(Attribute).getName() = "startswith" and
      methodCall.getArg(0) = urlLiteral and
      not urlLiteral.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*") and
      sanitizationCheck = methodCall
    )
    or
    // Case 3: Unsafe endswith usage
    exists(Call methodCall |
      methodCall.getFunc().(Attribute).getName() = "endswith" and
      methodCall.getArg(0) = urlLiteral and
      not urlLiteral.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+") and
      sanitizationCheck = methodCall
    )
  )
}

// Find expressions exhibiting incomplete URL substring sanitization patterns
from Expr sanitizationCheck, StringLiteral urlLiteral
where hasIncompleteSanitization(sanitizationCheck, urlLiteral)
select sanitizationCheck, "The string $@ may be at an arbitrary position in the sanitized URL.", urlLiteral,
  urlLiteral.getText()