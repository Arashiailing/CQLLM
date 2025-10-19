/**
 * @name Incomplete URL substring sanitization
 * @description Detects security vulnerabilities where URL validation relies on substring checks
 *              that can be bypassed by manipulating the URL structure.
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

// Defines regex pattern for identifying common top-level domains
private string getTldPattern() { result = "com|org|edu|gov|uk|net|io" }

// Determines if a string literal matches URL structural patterns
predicate matchesUrlStructure(StringLiteral urlStrLiteral) {
  exists(string literalContent | literalContent = urlStrLiteral.getText() |
    // Matches URLs with common TLDs (protocol and port are optional)
    literalContent.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + getTldPattern() +
        ")(:[0-9]+)?/?")
    or
    // Matches HTTP/HTTPS URLs with any top-level domain
    literalContent.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Detects potentially insecure prefix validation using startswith
predicate hasInsecurePrefixValidation(Call methodCall, StringLiteral urlStrLiteral) {
  methodCall.getFunc().(Attribute).getName() = "startswith" and
  methodCall.getArg(0) = urlStrLiteral and
  // Excludes patterns that include both protocol and path separator
  not urlStrLiteral.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*")
}

// Detects potentially insecure suffix validation using endswith
predicate hasInsecureSuffixValidation(Call methodCall, StringLiteral urlStrLiteral) {
  methodCall.getFunc().(Attribute).getName() = "endswith" and
  methodCall.getArg(0) = urlStrLiteral and
  // Excludes patterns with complete domain structure including multiple subdomains
  not urlStrLiteral.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+")
}

// Identifies sanitization operations that perform incomplete URL validation
predicate hasIncompleteUrlSanitization(Expr sanitizationOp, StringLiteral urlStrLiteral) {
  // First verify we're working with a URL-like string
  matchesUrlStructure(urlStrLiteral) and
  (
    // Case 1: Direct substring comparison without comprehensive validation
    sanitizationOp.(Compare).compares(urlStrLiteral, any(In i), _)
    or
    // Case 2: Potentially insecure prefix validation
    sanitizationOp instanceof Call and
    hasInsecurePrefixValidation(sanitizationOp.(Call), urlStrLiteral)
    or
    // Case 3: Potentially insecure suffix validation
    sanitizationOp instanceof Call and
    hasInsecureSuffixValidation(sanitizationOp.(Call), urlStrLiteral)
  )
}

// Main query: Locate expressions that perform incomplete URL substring sanitization
from Expr sanitizationOp, StringLiteral urlStrLiteral
where hasIncompleteUrlSanitization(sanitizationOp, urlStrLiteral)
select sanitizationOp, "The string $@ may be at an arbitrary position in the sanitized URL.", urlStrLiteral,
  urlStrLiteral.getText()