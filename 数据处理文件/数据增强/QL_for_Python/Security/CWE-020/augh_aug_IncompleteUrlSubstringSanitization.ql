/**
 * @name Incomplete URL substring sanitization
 * @description Security checks on the substrings of an unparsed URL are often vulnerable to bypassing.
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

// Defines regex pattern for common top-level domains
private string commonTldPattern() { result = "com|org|edu|gov|uk|net|io" }

// Checks if a string literal matches URL structure patterns
predicate isUrlLikeLiteral(StringLiteral urlStr) {
  exists(string content | content = urlStr.getText() |
    content.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + commonTldPattern() +
        ")(:[0-9]+)?/?")
    or
    // Matches HTTP URLs with any TLD
    content.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Identifies expressions with incomplete URL sanitization
predicate hasIncompleteSanitization(Expr checkExpr, StringLiteral urlLiteral) {
  isUrlLikeLiteral(urlLiteral) and
  (
    // Direct comparison operations
    checkExpr.(Compare).compares(urlLiteral, any(In i), _)
    or
    // Unsafe prefix checks
    exists(Call prefixCall | 
      prefixCall = checkExpr and
      prefixCall.getFunc().(Attribute).getName() = "startswith" and
      prefixCall.getArg(0) = urlLiteral and
      not urlLiteral.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*")
    )
    or
    // Unsafe suffix checks
    exists(Call suffixCall | 
      suffixCall = checkExpr and
      suffixCall.getFunc().(Attribute).getName() = "endswith" and
      suffixCall.getArg(0) = urlLiteral and
      not urlLiteral.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+")
    )
  )
}

// Query: Find expressions with incomplete URL substring sanitization
from Expr checkExpr, StringLiteral urlLiteral
where hasIncompleteSanitization(checkExpr, urlLiteral)
select checkExpr, "The string $@ may be at an arbitrary position in the sanitized URL.", urlLiteral,
  urlLiteral.getText()