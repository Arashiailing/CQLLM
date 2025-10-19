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
predicate matchesUrlStructure(StringLiteral urlStr) {
  exists(string urlText | urlText = urlStr.getText() |
    // Matches URLs with common TLDs (case-insensitive)
    urlText.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + getCommonTldPattern() +
        ")(:[0-9]+)?/?")
    or
    // Matches HTTP/HTTPS URLs with any TLD pattern
    urlText.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Detects unsafe prefix checks using startswith without complete URL path validation
predicate isInsecurePrefixCheck(Call prefixCheckCall, StringLiteral urlStr) {
  prefixCheckCall.getFunc().(Attribute).getName() = "startswith" and
  prefixCheckCall.getArg(0) = urlStr and
  // Exclude cases where full URL path structure is validated
  not urlStr.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*")
}

// Detects unsafe suffix checks using endswith without proper domain hierarchy validation
predicate isInsecureSuffixCheck(Call suffixCheckCall, StringLiteral urlStr) {
  suffixCheckCall.getFunc().(Attribute).getName() = "endswith" and
  suffixCheckCall.getArg(0) = urlStr and
  // Exclude cases with proper multi-level domain structure
  not urlStr.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+")
}

// Identifies sanitization operations that fail to validate complete URL structure
predicate hasIncompleteUrlValidation(Expr validationExpr, StringLiteral urlStr) {
  matchesUrlStructure(urlStr) and
  (
    // Insecure prefix validation without full URL verification
    isInsecurePrefixCheck(validationExpr, urlStr)
    or
    // Insecure suffix validation without proper domain validation
    isInsecureSuffixCheck(validationExpr, urlStr)
    or
    // Direct string comparison operations
    validationExpr.(Compare).compares(urlStr, any(In i), _)
  )
}

// Query: Locate expressions performing incomplete URL substring sanitization
from Expr validationExpr, StringLiteral urlStr
where hasIncompleteUrlValidation(validationExpr, urlStr)
select validationExpr, "The string $@ may be at an arbitrary position in the sanitized URL.", urlStr,
  urlStr.getText()