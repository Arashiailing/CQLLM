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
predicate isUrlLike(StringLiteral urlStr) {
  exists(string text | text = urlStr.getText() |
    text.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + commonTldPattern() + ")(:[0-9]+)?/?")
    or
    // Alternative pattern for HTTP URLs with arbitrary TLDs
    text.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Identifies inadequate sanitization operations applied to URL substrings
predicate hasInsufficientSanitization(Expr sanitExpr, StringLiteral urlStr) {
  isUrlLike(urlStr) and
  (
    // Case 1: Direct comparison operations
    exists(Compare cmp |
      cmp.compares(urlStr, any(In i), _) and
      sanitExpr = cmp
    )
    or
    // Case 2: Unsafe prefix validation
    exists(Call startCall |
      startCall.getFunc().(Attribute).getName() = "startswith" and
      startCall.getArg(0) = urlStr and
      not urlStr.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*") and
      sanitExpr = startCall
    )
    or
    // Case 3: Unsafe suffix validation
    exists(Call endCall |
      endCall.getFunc().(Attribute).getName() = "endswith" and
      endCall.getArg(0) = urlStr and
      not urlStr.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+") and
      sanitExpr = endCall
    )
  )
}

// Main query: Finds expressions with incomplete URL substring sanitization
from Expr sanitExpr, StringLiteral urlStr
where hasInsufficientSanitization(sanitExpr, urlStr)
select sanitExpr, "The string $@ may be at an arbitrary position in the sanitized URL.", urlStr,
  urlStr.getText()