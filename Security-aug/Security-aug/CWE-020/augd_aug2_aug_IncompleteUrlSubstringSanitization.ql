/**
 * @name Incomplete URL substring sanitization
 * @description Detects security checks on URL substrings that lack proper parsing,
 *              making them vulnerable to bypass techniques.
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
private string standardTldPattern() { result = "com|org|edu|gov|uk|net|io" }

// Determines if a string literal exhibits URL-like structural patterns
predicate matchesUrlStructure(StringLiteral urlLiteral) {
  exists(string literalContent | literalContent = urlLiteral.getText() |
    literalContent.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + standardTldPattern() +
        ")(:[0-9]+)?/?")
    or
    // Alternative pattern for HTTP URLs with any TLD
    literalContent.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Identifies inadequate sanitization operations performed on URL substrings
predicate hasInsufficientSanitization(Expr sanitizationOperation, StringLiteral urlLiteral) {
  matchesUrlStructure(urlLiteral) and
  (
    sanitizationOperation.(Compare).compares(urlLiteral, any(In i), _)
    or
    unsafePrefixValidation(sanitizationOperation, urlLiteral)
    or
    unsafeSuffixValidation(sanitizationOperation, urlLiteral)
  )
}

// Detects unsafe startswith operations against URL string literals
predicate unsafePrefixValidation(Call methodInvocation, StringLiteral urlLiteral) {
  methodInvocation.getFunc().(Attribute).getName() = "startswith" and
  methodInvocation.getArg(0) = urlLiteral and
  not urlLiteral.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*")
}

// Detects unsafe endswith operations against URL string literals
predicate unsafeSuffixValidation(Call methodInvocation, StringLiteral urlLiteral) {
  methodInvocation.getFunc().(Attribute).getName() = "endswith" and
  methodInvocation.getArg(0) = urlLiteral and
  not urlLiteral.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+")
}

// Main query: Locates expressions with incomplete URL substring sanitization
from Expr sanitizationOperation, StringLiteral urlLiteral
where hasInsufficientSanitization(sanitizationOperation, urlLiteral)
select sanitizationOperation, "The string $@ may be at an arbitrary position in the sanitized URL.", urlLiteral,
  urlLiteral.getText()