/**
 * @name Confusing octal literal
 * @description Octal literal with a leading 0 is easily misread as a decimal value
 * @kind problem
 * @tags readability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision high
 * @id py/old-style-octal-literal
 */

import python

/**
 * Detects integer literals using legacy octal notation (leading 0 without 0o prefix).
 * These literals appear decimal but are interpreted as octal, causing confusion.
 * Excludes special cases like "00" and common file permission patterns (length 4,5,7).
 */
predicate uses_legacy_octal_format(IntegerLiteral oldOctalLiteral) {
  exists(string textContent | 
    textContent = oldOctalLiteral.getText() and
    // Must start with '0' indicating potential octal notation
    textContent.charAt(0) = "0" and
    // Exclude special case "00"
    not textContent = "00" and
    // Verify second character is a digit (required for octal numbers)
    exists(textContent.charAt(1).toInt()) and
    // Filter out common file permission patterns by length
    not textContent.length() in [4, 5, 7]
  )
}

// Identify all integer literals using confusing legacy octal notation
from IntegerLiteral oldOctalLiteral
where uses_legacy_octal_format(oldOctalLiteral)
select oldOctalLiteral, "Confusing octal literal, use 0o" + oldOctalLiteral.getText().suffix(1) + " instead."