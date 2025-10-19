/**
 * @name Incomplete URL substring sanitization
 * @description Security checks that operate on substrings of unparsed URLs are vulnerable to bypass attacks, 
 *              as they don't account for the entire URL structure. This query identifies patterns where
 *              security validations are performed on URL substrings without proper parsing.
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
predicate hasUrlPattern(StringLiteral urlLiteral) {
  exists(string literalContent | literalContent = urlLiteral.getText() |
    literalContent.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + commonTldPattern() + ")(:[0-9]+)?/?")
    or
    literalContent.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Case 1: Detects direct string comparison operations on URL substrings
predicate isDirectComparison(Expr sanitizationOperation, StringLiteral urlLiteral) {
  exists(Compare comparisonOp | 
    comparisonOp.compares(urlLiteral, any(In i), _) and
    sanitizationOperation = comparisonOp
  )
}

// Case 2: Detects unsafe startswith usage on URL substrings
predicate isUnsafeStartswith(Expr sanitizationOperation, StringLiteral urlLiteral) {
  exists(Call methodCall | 
    methodCall.getFunc().(Attribute).getName() = "startswith" and
    methodCall.getArg(0) = urlLiteral and
    not urlLiteral.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*") and
    sanitizationOperation = methodCall
  )
}

// Case 3: Detects unsafe endswith usage on URL substrings
predicate isUnsafeEndswith(Expr sanitizationOperation, StringLiteral urlLiteral) {
  exists(Call methodCall | 
    methodCall.getFunc().(Attribute).getName() = "endswith" and
    methodCall.getArg(0) = urlLiteral and
    not urlLiteral.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+") and
    sanitizationOperation = methodCall
  )
}

// Detects expressions performing incomplete URL substring sanitization
predicate hasIncompleteSanitization(Expr sanitizationOperation, StringLiteral urlLiteral) {
  hasUrlPattern(urlLiteral) and
  (
    isDirectComparison(sanitizationOperation, urlLiteral)
    or
    isUnsafeStartswith(sanitizationOperation, urlLiteral)
    or
    isUnsafeEndswith(sanitizationOperation, urlLiteral)
  )
}

// Find expressions exhibiting incomplete URL substring sanitization patterns
from Expr sanitizationOperation, StringLiteral urlLiteral
where hasIncompleteSanitization(sanitizationOperation, urlLiteral)
select sanitizationOperation, "The string $@ may be at an arbitrary position in the sanitized URL.", urlLiteral,
  urlLiteral.getText()