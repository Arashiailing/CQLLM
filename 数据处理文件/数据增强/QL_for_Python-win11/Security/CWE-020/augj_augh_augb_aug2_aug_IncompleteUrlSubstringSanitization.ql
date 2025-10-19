/**
 * @name Incomplete URL substring sanitization
 * @description Identifies security vulnerabilities where URL substrings are validated using inadequate parsing techniques that can be circumvented.
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

// Generates regex pattern for commonly used top-level domains
private string getCommonTldPattern() { result = "com|org|edu|gov|uk|net|io" }

// Determines if a string literal resembles a URL structure
predicate resemblesUrl(StringLiteral urlLiteral) {
  exists(string content | content = urlLiteral.getText() |
    // Pattern 1: URLs with common TLDs
    content.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + getCommonTldPattern() + ")(:[0-9]+)?/?")
    or
    // Pattern 2: HTTP URLs with arbitrary TLDs
    content.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Identifies insufficient sanitization operations on URL substrings
predicate hasInadequateSanitization(Expr sanitizationOp, StringLiteral urlLiteral) {
  resemblesUrl(urlLiteral) and
  (
    // Case 1: Direct comparison operations
    sanitizationOp.(Compare).compares(urlLiteral, any(In i), _)
    or
    // Case 2: Unsafe prefix validation
    exists(Call prefixValidation |
      prefixValidation.getFunc().(Attribute).getName() = "startswith" and
      prefixValidation.getArg(0) = urlLiteral and
      not urlLiteral.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*") and
      sanitizationOp = prefixValidation
    )
    or
    // Case 3: Unsafe suffix validation
    exists(Call suffixValidation |
      suffixValidation.getFunc().(Attribute).getName() = "endswith" and
      suffixValidation.getArg(0) = urlLiteral and
      not urlLiteral.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+") and
      sanitizationOp = suffixValidation
    )
  )
}

// Main query: Locates expressions with incomplete URL substring sanitization
from Expr sanitizationOp, StringLiteral urlLiteral
where hasInadequateSanitization(sanitizationOp, urlLiteral)
select sanitizationOp, "The string $@ may be at an arbitrary position in the sanitized URL.", urlLiteral,
  urlLiteral.getText()