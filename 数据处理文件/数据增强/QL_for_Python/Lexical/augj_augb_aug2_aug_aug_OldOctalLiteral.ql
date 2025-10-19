/**
 * @name Ambiguous octal literal notation
 * @description Legacy octal literals (leading 0) are visually deceptive as they resemble decimal values
 * @kind problem
 * @tags readability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision high
 * @id py/old-style-octal-literal
 */

import python

/**
 * Detects integer literals using outdated octal format (0 prefix without 0o)
 * This notation creates confusion between decimal and octal interpretations
 * Excludes: "00" and common file permission patterns (lengths 4,5,7)
 */
predicate uses_legacy_octal_notation(IntegerLiteral oldOctalLiteral) {
  exists(string rawText | 
    rawText = oldOctalLiteral.getText() and
    // Must start with '0' to indicate potential octal notation
    rawText.charAt(0) = "0" and
    // Verify second character is a valid octal digit
    exists(rawText.charAt(1).toInt()) and
    // Exclude special cases and permission patterns
    not (rawText = "00" or rawText.length() in [4, 5, 7])
  )
}

// Identify all integer literals with misleading legacy octal notation
from IntegerLiteral oldOctalLiteral
where uses_legacy_octal_notation(oldOctalLiteral)
select oldOctalLiteral, "Ambiguous octal literal, use 0o" + oldOctalLiteral.getText().suffix(1) + " instead."