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

// Returns regex pattern matching common top-level domains
private string getCommonTLDRegex() { result = "com|org|edu|gov|uk|net|io" }

// Determines if a string literal resembles a URL structure
predicate resemblesUrl(StringLiteral urlStr) {
  exists(string content | content = urlStr.getText() |
    content.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + getCommonTLDRegex() +
        ")(:[0-9]+)?/?")
    or
    // Matches HTTP URLs with any TLD
    content.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Identifies incomplete sanitization operations on URL substrings
predicate hasIncompleteUrlSanitization(Expr sanitizationOp, StringLiteral urlLiteral) {
  resemblesUrl(urlLiteral) and
  (
    sanitizationOp.(Compare).compares(urlLiteral, any(In i), _)
    or
    isUnsafePrefixCheck(sanitizationOp, urlLiteral)
    or
    isUnsafeSuffixCheck(sanitizationOp, urlLiteral)
  )
}

// Detects unsafe startswith operations on URLs
predicate isUnsafePrefixCheck(Call sanitizationCall, StringLiteral urlLiteral) {
  sanitizationCall.getFunc().(Attribute).getName() = "startswith" and
  sanitizationCall.getArg(0) = urlLiteral and
  not urlLiteral.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*")
}

// Detects unsafe endswith operations on URLs
predicate isUnsafeSuffixCheck(Call sanitizationCall, StringLiteral urlLiteral) {
  sanitizationCall.getFunc().(Attribute).getName() = "endswith" and
  sanitizationCall.getArg(0) = urlLiteral and
  not urlLiteral.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+")
}

// Query: Find expressions with incomplete URL substring sanitization
from Expr sanitizationOp, StringLiteral urlLiteral
where hasIncompleteUrlSanitization(sanitizationOp, urlLiteral)
select sanitizationOp, "The string $@ may be at an arbitrary position in the sanitized URL.", urlLiteral,
  urlLiteral.getText()