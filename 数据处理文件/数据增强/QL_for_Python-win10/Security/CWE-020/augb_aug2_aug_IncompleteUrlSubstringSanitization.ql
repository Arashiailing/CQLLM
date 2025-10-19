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
  exists(string literalText | literalText = urlLiteral.getText() |
    literalText.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + commonTldPattern() +
        ")(:[0-9]+)?/?")
    or
    // Alternative pattern for HTTP URLs with arbitrary TLDs
    literalText.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Identifies inadequate sanitization operations applied to URL substrings
predicate hasInsufficientSanitization(Expr sanitizationOperation, StringLiteral urlLiteral) {
  isUrlLike(urlLiteral) and
  (
    sanitizationOperation.(Compare).compares(urlLiteral, any(In i), _)
    or
    // Detects unsafe startswith operations on URL strings
    exists(Call prefixCall |
      prefixCall.getFunc().(Attribute).getName() = "startswith" and
      prefixCall.getArg(0) = urlLiteral and
      not urlLiteral.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*") and
      sanitizationOperation = prefixCall
    )
    or
    // Detects unsafe endswith operations on URL strings
    exists(Call suffixCall |
      suffixCall.getFunc().(Attribute).getName() = "endswith" and
      suffixCall.getArg(0) = urlLiteral and
      not urlLiteral.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+") and
      sanitizationOperation = suffixCall
    )
  )
}

// Main query: Finds expressions with incomplete URL substring sanitization
from Expr sanitizationOperation, StringLiteral urlLiteral
where hasInsufficientSanitization(sanitizationOperation, urlLiteral)
select sanitizationOperation, "The string $@ may be at an arbitrary position in the sanitized URL.", urlLiteral,
  urlLiteral.getText()