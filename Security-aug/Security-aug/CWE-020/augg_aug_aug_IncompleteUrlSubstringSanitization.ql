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

// Regex pattern for common top-level domains (TLDs) used in URL validation
private string getCommonTldPattern() { result = "com|org|edu|gov|uk|net|io" }

// Determines if a string literal exhibits URL-like structural characteristics
predicate matchesUrlStructure(StringLiteral urlLiteral) {
  exists(string urlText | urlText = urlLiteral.getText() |
    // Matches URLs with common TLDs (case-insensitive)
    urlText.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + getCommonTldPattern() +
        ")(:[0-9]+)?/?")
    or
    // Matches HTTP/HTTPS URLs with any TLD pattern
    urlText.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Identifies sanitization operations that fail to validate complete URL structure
predicate hasIncompleteUrlValidation(Expr sanitizationExpr, StringLiteral urlLiteral) {
  matchesUrlStructure(urlLiteral) and
  (
    // Direct string comparison operations
    sanitizationExpr.(Compare).compares(urlLiteral, any(In i), _)
    or
    // Insecure prefix validation without full URL verification
    isInsecurePrefixCheck(sanitizationExpr, urlLiteral)
    or
    // Insecure suffix validation without proper domain validation
    isInsecureSuffixCheck(sanitizationExpr, urlLiteral)
  )
}

// Detects unsafe prefix checks using startswith without complete URL path validation
predicate isInsecurePrefixCheck(Call validationCall, StringLiteral urlLiteral) {
  validationCall.getFunc().(Attribute).getName() = "startswith" and
  validationCall.getArg(0) = urlLiteral and
  // Exclude cases where full URL path structure is validated
  not urlLiteral.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*")
}

// Detects unsafe suffix checks using endswith without proper domain hierarchy validation
predicate isInsecureSuffixCheck(Call validationCall, StringLiteral urlLiteral) {
  validationCall.getFunc().(Attribute).getName() = "endswith" and
  validationCall.getArg(0) = urlLiteral and
  // Exclude cases with proper multi-level domain structure
  not urlLiteral.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+")
}

// Query: Locate expressions performing incomplete URL substring sanitization
from Expr sanitizationExpr, StringLiteral urlLiteral
where hasIncompleteUrlValidation(sanitizationExpr, urlLiteral)
select sanitizationExpr, "The string $@ may be at an arbitrary position in the sanitized URL.", urlLiteral,
  urlLiteral.getText()