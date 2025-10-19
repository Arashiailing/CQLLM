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

// Defines a regex pattern capturing commonly used top-level domains
private string getTopLevelDomainPattern() { 
  result = "com|org|edu|gov|uk|net|io" 
}

// Determines if a string literal exhibits URL-like characteristics
predicate showsUrlCharacteristics(StringLiteral urlStrLiteral) {
  exists(string strContent | strContent = urlStrLiteral.getText() |
    // Matches URLs that include common TLDs
    strContent.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + getTopLevelDomainPattern() +
        ")(:[0-9]+)?/?")
    or
    // Matches HTTP/HTTPS URLs with any TLD
    strContent.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Identifies expressions that perform inadequate URL sanitization
predicate performsIncompleteUrlSanitization(Expr sanitizationOp, StringLiteral urlStrLiteral) {
  showsUrlCharacteristics(urlStrLiteral) and
  (
    // Identifies comparison-based checks
    sanitizationOp.(Compare).compares(urlStrLiteral, any(In i), _)
    or
    // Identifies risky prefix validations
    isRiskyPrefixValidation(sanitizationOp, urlStrLiteral)
    or
    // Identifies risky suffix validations
    isRiskySuffixValidation(sanitizationOp, urlStrLiteral)
  )
}

// Detects potentially unsafe startswith operations on URL strings
predicate isRiskyPrefixValidation(Call sanitizationOp, StringLiteral urlStrLiteral) {
  sanitizationOp.getFunc().(Attribute).getName() = "startswith" and
  sanitizationOp.getArg(0) = urlStrLiteral and
  // Excludes URLs with properly formatted protocol prefixes
  not urlStrLiteral.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*")
}

// Detects potentially unsafe endswith operations on URL strings
predicate isRiskySuffixValidation(Call sanitizationOp, StringLiteral urlStrLiteral) {
  sanitizationOp.getFunc().(Attribute).getName() = "endswith" and
  sanitizationOp.getArg(0) = urlStrLiteral and
  // Excludes properly formatted domain endings
  not urlStrLiteral.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+")
}

// Main query: Locates expressions performing incomplete URL substring sanitization
from Expr sanitizationOp, StringLiteral urlStrLiteral
where performsIncompleteUrlSanitization(sanitizationOp, urlStrLiteral)
select sanitizationOp, "The string $@ may be at an arbitrary position in the sanitized URL.", urlStrLiteral,
  urlStrLiteral.getText()