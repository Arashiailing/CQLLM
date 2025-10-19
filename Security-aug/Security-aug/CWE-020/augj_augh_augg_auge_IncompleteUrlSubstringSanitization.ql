/**
 * @name Incomplete URL substring sanitization
 * @description Detects insufficient security validation when checking URL substrings without proper parsing,
 *              which can be bypassed using various techniques.
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

// Defines a regex pattern capturing widely used top-level domains for URL validation purposes
private string getTopLevelDomainPattern() { result = "com|org|edu|gov|uk|net|io" }

// Checks whether a string literal exhibits characteristics of a URL format
predicate resemblesUrlStructure(StringLiteral urlLiteral) {
  exists(string literalContent | literalContent = urlLiteral.getText() |
    // Identifies URLs containing common TLDs
    literalContent.regexpMatch("(?i)([a-z]*:?//)?\\.?([a-z0-9-]+\\.)+(" + getTopLevelDomainPattern() +
        ")(:[0-9]+)?/?")
    or
    // Recognizes HTTP/HTTPS URLs with any top-level domain
    literalContent.regexpMatch("(?i)https?://([a-z0-9-]+\\.)+([a-z]+)(:[0-9]+)?/?")
  )
}

// Identifies inadequate sanitization approaches that don't validate complete URL architecture
predicate performsIncompleteUrlSanitization(Expr sanitizationOperation, StringLiteral urlLiteral) {
  resemblesUrlStructure(urlLiteral) and
  (
    // Direct string comparison operations
    sanitizationOperation.(Compare).compares(urlLiteral, any(In i), _)
    or
    // Insufficient prefix validation techniques
    employsUnsafePrefixValidation(sanitizationOperation, urlLiteral)
    or
    // Inadequate suffix validation approaches
    employsUnsafeSuffixValidation(sanitizationOperation, urlLiteral)
  )
}

// Recognizes startswith method calls that don't validate the complete URL structure
predicate employsUnsafePrefixValidation(Call methodCall, StringLiteral urlLiteral) {
  methodCall.getFunc().(Attribute).getName() = "startswith" and
  methodCall.getArg(0) = urlLiteral and
  not urlLiteral.getText().regexpMatch("(?i)https?://[\\.a-z0-9-]+/.*")
}

// Detects endswith method calls that fail to validate proper domain hierarchy
predicate employsUnsafeSuffixValidation(Call methodCall, StringLiteral urlLiteral) {
  methodCall.getFunc().(Attribute).getName() = "endswith" and
  methodCall.getArg(0) = urlLiteral and
  not urlLiteral.getText().regexpMatch("(?i)\\.([a-z0-9-]+)(\\.[a-z0-9-]+)+")
}

// Primary query: Finds expressions that implement incomplete URL substring sanitization
from Expr sanitizationOperation, StringLiteral urlLiteral
where performsIncompleteUrlSanitization(sanitizationOperation, urlLiteral)
select sanitizationOperation, "The string $@ may be at an arbitrary position in the sanitized URL.", urlLiteral,
  urlLiteral.getText()