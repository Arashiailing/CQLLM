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

// Defines regex pattern for common top-level domains used in URL validation
private string commonTldPattern() { result = "com|org|edu|gov|uk|net|io" }

// Determines if a string literal exhibits URL-like characteristics
predicate isUrlLike(StringLiteral urlLiteral) {
  exists(string urlContent | urlContent = urlLiteral.getText() |
    // Match URLs with common TLDs
    urlContent.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + commonTldPattern() +
        ")(:[0-9]+)?/?")
    or
    // Match HTTP/HTTPS URLs with any TLD
    urlContent.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Identifies incomplete sanitization attempts on URL substrings
predicate hasIncompleteUrlSanitization(Expr sanitizationExpr, StringLiteral urlLiteral) {
  isUrlLike(urlLiteral) and
  (
    // Direct comparison operations
    sanitizationExpr.(Compare).compares(urlLiteral, any(In i), _)
    or
    // Unsafe prefix checks
    isUnsafeStartswith(sanitizationExpr, urlLiteral)
    or
    // Unsafe suffix checks
    isUnsafeEndswith(sanitizationExpr, urlLiteral)
  )
}

// Detects unsafe startswith calls that don't validate full URL structure
predicate isUnsafeStartswith(Call callNode, StringLiteral urlLiteral) {
  callNode.getFunc().(Attribute).getName() = "startswith" and
  callNode.getArg(0) = urlLiteral and
  not urlLiteral.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*")
}

// Detects unsafe endswith calls that don't validate domain structure
predicate isUnsafeEndswith(Call callNode, StringLiteral urlLiteral) {
  callNode.getFunc().(Attribute).getName() = "endswith" and
  callNode.getArg(0) = urlLiteral and
  not urlLiteral.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+")
}

// Main query: Find expressions with incomplete URL substring sanitization
from Expr sanitizationExpr, StringLiteral urlLiteral
where hasIncompleteUrlSanitization(sanitizationExpr, urlLiteral)
select sanitizationExpr, "The string $@ may be at an arbitrary position in the sanitized URL.", urlLiteral,
  urlLiteral.getText()