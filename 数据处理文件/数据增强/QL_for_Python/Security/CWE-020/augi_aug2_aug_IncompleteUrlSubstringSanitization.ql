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
private string commonTldPattern() { 
  result = "com|org|edu|gov|uk|net|io" 
}

// Checks if string literal matches URL structure patterns
predicate isUrlLike(StringLiteral urlLiteral) {
  exists(string textContent | 
    textContent = urlLiteral.getText() and
    (
      // Match URLs with common TLDs
      textContent.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + commonTldPattern() +
          ")(:[0-9]+)?/?")
      or
      // Match HTTP URLs with any TLD
      textContent.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
    )
  )
}

// Identifies insufficient sanitization operations on URL substrings
predicate hasInsufficientSanitization(Expr sanitizationOperation, StringLiteral urlLiteral) {
  isUrlLike(urlLiteral) and
  (
    // Detect comparison operations
    sanitizationOperation.(Compare).compares(urlLiteral, any(In i), _)
    or
    // Detect unsafe prefix checks
    unsafePrefixCheck(sanitizationOperation, urlLiteral)
    or
    // Detect unsafe suffix checks
    unsafeSuffixCheck(sanitizationOperation, urlLiteral)
  )
}

// Detects unsafe startswith operations on URL strings
predicate unsafePrefixCheck(Call methodInvocation, StringLiteral urlLiteral) {
  methodInvocation.getFunc().(Attribute).getName() = "startswith" and
  methodInvocation.getArg(0) = urlLiteral and
  // Exclude properly formatted HTTP URLs with paths
  not urlLiteral.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*")
}

// Detects unsafe endswith operations on URL strings
predicate unsafeSuffixCheck(Call methodInvocation, StringLiteral urlLiteral) {
  methodInvocation.getFunc().(Attribute).getName() = "endswith" and
  methodInvocation.getArg(0) = urlLiteral and
  // Exclude properly formatted domain endings
  not urlLiteral.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+")
}

// Main query: Find expressions with incomplete URL substring sanitization
from Expr sanitizationOperation, StringLiteral urlLiteral
where hasInsufficientSanitization(sanitizationOperation, urlLiteral)
select sanitizationOperation, "The string $@ may be at an arbitrary position in the sanitized URL.", urlLiteral,
  urlLiteral.getText()