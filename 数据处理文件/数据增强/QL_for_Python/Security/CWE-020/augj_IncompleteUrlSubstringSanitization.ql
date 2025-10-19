/**
 * @name Incomplete URL substring sanitization
 * @description Detects incomplete sanitization of URL substrings, which may allow bypassing security checks.
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

// Private helper function providing regex pattern for common top-level domains
private string topLevelDomainPattern() { result = "com|org|edu|gov|uk|net|io" }

// Determines if a string literal resembles a URL structure
predicate resemblesUrl(StringLiteral strLiteral) {
  exists(string content | content = strLiteral.getText() |
    content.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + topLevelDomainPattern() +
        ")(:[0-9]+)?/?")
    or
    // Matches HTTP URLs with any top-level domain
    content.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Identifies incomplete sanitization attempts on URL substrings
predicate incompleteUrlSanitization(Expr sanitizationExpr, StringLiteral urlLiteral) {
  resemblesUrl(urlLiteral) and
  (
    sanitizationExpr.(Compare).compares(urlLiteral, any(In i), _)
    or
    vulnerableStartswithCall(sanitizationExpr, urlLiteral)
    or
    vulnerableEndswithCall(sanitizationExpr, urlLiteral)
  )
}

// Detects unsafe startswith() calls that don't cover full URL structure
predicate vulnerableStartswithCall(Call sanitizationCall, StringLiteral urlLiteral) {
  sanitizationCall.getFunc().(Attribute).getName() = "startswith" and
  sanitizationCall.getArg(0) = urlLiteral and
  not urlLiteral.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*")
}

// Detects unsafe endswith() calls that don't cover full domain structure
predicate vulnerableEndswithCall(Call sanitizationCall, StringLiteral urlLiteral) {
  sanitizationCall.getFunc().(Attribute).getName() = "endswith" and
  sanitizationCall.getArg(0) = urlLiteral and
  not urlLiteral.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+")
}

// Main query: Find expressions performing incomplete URL substring sanitization
from Expr sanitizationExpr, StringLiteral urlLiteral
where incompleteUrlSanitization(sanitizationExpr, urlLiteral)
select sanitizationExpr, "The string $@ may be at an arbitrary position in the sanitized URL.", urlLiteral,
  urlLiteral.getText()