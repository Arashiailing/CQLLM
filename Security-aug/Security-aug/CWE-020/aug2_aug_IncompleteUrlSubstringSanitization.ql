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

// Checks if string literal matches URL structure patterns
predicate isUrlLike(StringLiteral urlStr) {
  exists(string textContent | textContent = urlStr.getText() |
    textContent.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + commonTldPattern() +
        ")(:[0-9]+)?/?")
    or
    // Alternative pattern for HTTP URLs with any TLD
    textContent.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Identifies insufficient sanitization operations on URL substrings
predicate hasInsufficientSanitization(Expr sanitizationExpr, StringLiteral urlStr) {
  isUrlLike(urlStr) and
  (
    sanitizationExpr.(Compare).compares(urlStr, any(In i), _)
    or
    unsafePrefixCheck(sanitizationExpr, urlStr)
    or
    unsafeSuffixCheck(sanitizationExpr, urlStr)
  )
}

// Detects unsafe startswith operations on URL strings
predicate unsafePrefixCheck(Call methodCall, StringLiteral urlStr) {
  methodCall.getFunc().(Attribute).getName() = "startswith" and
  methodCall.getArg(0) = urlStr and
  not urlStr.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*")
}

// Detects unsafe endswith operations on URL strings
predicate unsafeSuffixCheck(Call methodCall, StringLiteral urlStr) {
  methodCall.getFunc().(Attribute).getName() = "endswith" and
  methodCall.getArg(0) = urlStr and
  not urlStr.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+")
}

// Main query: Find expressions with incomplete URL substring sanitization
from Expr sanitizationExpr, StringLiteral urlStr
where hasInsufficientSanitization(sanitizationExpr, urlStr)
select sanitizationExpr, "The string $@ may be at an arbitrary position in the sanitized URL.", urlStr,
  urlStr.getText()