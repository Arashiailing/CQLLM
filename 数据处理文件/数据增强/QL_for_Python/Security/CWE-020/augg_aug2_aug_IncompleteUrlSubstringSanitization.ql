/**
 * @name Incomplete URL substring sanitization
 * @description Security checks on URL substrings without proper parsing are vulnerable to bypass techniques.
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

// Generates regex pattern for common top-level domains
private string commonTldPattern() { result = "com|org|edu|gov|uk|net|io" }

// Determines if a string literal resembles a URL structure
predicate isUrlLike(StringLiteral urlLiteral) {
  exists(string textContent | textContent = urlLiteral.getText() |
    textContent.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + commonTldPattern() +
        ")(:[0-9]+)?/?")
    or
    // Alternative pattern for HTTP URLs with any TLD
    textContent.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Identifies inadequate sanitization operations applied to URL substrings
predicate hasInsufficientSanitization(Expr sanitizationOperation, StringLiteral urlLiteral) {
  isUrlLike(urlLiteral) and
  (
    sanitizationOperation.(Compare).compares(urlLiteral, any(In i), _)
    or
    unsafePrefixCheck(sanitizationOperation, urlLiteral)
    or
    unsafeSuffixCheck(sanitizationOperation, urlLiteral)
  )
}

// Detects unsafe startswith operations on URL strings
predicate unsafePrefixCheck(Call callExpr, StringLiteral urlLiteral) {
  callExpr.getFunc().(Attribute).getName() = "startswith" and
  callExpr.getArg(0) = urlLiteral and
  not urlLiteral.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*")
}

// Detects unsafe endswith operations on URL strings
predicate unsafeSuffixCheck(Call callExpr, StringLiteral urlLiteral) {
  callExpr.getFunc().(Attribute).getName() = "endswith" and
  callExpr.getArg(0) = urlLiteral and
  not urlLiteral.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+")
}

// Main query: Locate expressions with incomplete URL substring sanitization
from Expr sanitizationOperation, StringLiteral urlLiteral
where hasInsufficientSanitization(sanitizationOperation, urlLiteral)
select sanitizationOperation, "The string $@ may be at an arbitrary position in the sanitized URL.", urlLiteral,
  urlLiteral.getText()