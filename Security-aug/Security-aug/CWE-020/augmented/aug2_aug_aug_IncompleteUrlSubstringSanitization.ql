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

// Returns regex pattern for common top-level domains used in URL validation
private string getCommonTldPattern() { result = "com|org|edu|gov|uk|net|io" }

// Checks if string literal matches URL structure patterns
predicate resemblesUrl(StringLiteral urlStr) {
  exists(string text | text = urlStr.getText() |
    text.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + getCommonTldPattern() +
        ")(:[0-9]+)?/?")
    or
    text.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Detects unsafe startswith checks for URL validation
predicate hasUnsafeStartswithCheck(Call callNode, StringLiteral urlStr) {
  callNode.getFunc().(Attribute).getName() = "startswith" and
  callNode.getArg(0) = urlStr and
  not urlStr.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*")
}

// Detects unsafe endswith checks for URL validation
predicate hasUnsafeEndswithCheck(Call callNode, StringLiteral urlStr) {
  callNode.getFunc().(Attribute).getName() = "endswith" and
  callNode.getArg(0) = urlStr and
  not urlStr.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+")
}

// Identifies incomplete sanitization operations on URL substrings
predicate hasIncompleteUrlSanitization(Expr sanitOp, StringLiteral urlStr) {
  resemblesUrl(urlStr) and
  (
    sanitOp.(Compare).compares(urlStr, any(In i), _)
    or
    hasUnsafeStartswithCheck(sanitOp, urlStr)
    or
    hasUnsafeEndswithCheck(sanitOp, urlStr)
  )
}

// Main query: Find expressions with incomplete URL substring sanitization
from Expr sanitOp, StringLiteral urlStr
where hasIncompleteUrlSanitization(sanitOp, urlStr)
select sanitOp, "The string $@ may be at an arbitrary position in the sanitized URL.", urlStr,
  urlStr.getText()