/**
 * @name Incomplete URL substring sanitization
 * @description Security checks on substrings of unparsed URLs are vulnerable to bypass
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
private string getCommonTldRegex() { result = "com|org|edu|gov|uk|net|io" }

// Checks if string literal matches URL patterns
predicate isUrlLike(StringLiteral urlStr) {
  exists(string strContent | strContent = urlStr.getText() |
    // Matches URLs with protocol and domain structure
    strContent.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + getCommonTldRegex() +
        ")(:[0-9]+)?/?")
    or
    // Matches standard HTTP/HTTPS URLs
    strContent.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Detects unsafe startswith validation for URLs
predicate hasUnsafeStartswithValidation(Call methodInvocation, StringLiteral urlStr) {
  methodInvocation.getFunc().(Attribute).getName() = "startswith" and
  methodInvocation.getArg(0) = urlStr and
  // Excludes properly formatted protocol prefixes
  not urlStr.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*")
}

// Detects unsafe endswith validation for URLs
predicate hasUnsafeEndswithValidation(Call methodInvocation, StringLiteral urlStr) {
  methodInvocation.getFunc().(Attribute).getName() = "endswith" and
  methodInvocation.getArg(0) = urlStr and
  // Excludes proper domain suffix patterns
  not urlStr.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+")
}

// Identifies incomplete URL sanitization patterns
predicate hasIncompleteUrlSanitization(Expr sanitizedExpr, StringLiteral urlStr) {
  isUrlLike(urlStr) and
  (
    // Direct comparison operations
    sanitizedExpr.(Compare).compares(urlStr, any(In i), _)
    or
    // Unsafe prefix checks
    hasUnsafeStartswithValidation(sanitizedExpr, urlStr)
    or
    // Unsafe suffix checks
    hasUnsafeEndswithValidation(sanitizedExpr, urlStr)
  )
}

// Main query detecting expressions with incomplete URL substring sanitization
from Expr sanitizedExpr, StringLiteral urlStr
where hasIncompleteUrlSanitization(sanitizedExpr, urlStr)
select sanitizedExpr, "The string $@ may be at an arbitrary position in the sanitized URL.", urlStr,
  urlStr.getText()