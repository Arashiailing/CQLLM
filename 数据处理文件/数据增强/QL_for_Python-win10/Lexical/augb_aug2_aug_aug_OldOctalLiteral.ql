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
 * Identifies integer literals employing legacy octal notation (leading 0 without 0o prefix)
 * This notation is misleading as it visually resembles decimal numbers but has a different value
 * Exclusions: "00" and typical file permission representations (length 4, 5, or 7)
 */
predicate uses_legacy_octal_notation(IntegerLiteral legacyOctalLiteral) {
  exists(string literalText | 
    literalText = legacyOctalLiteral.getText() and
    // Verify literal begins with '0', indicating potential octal notation
    literalText.charAt(0) = "0" and
    // Exclude the special case "00"
    not literalText = "00" and
    // Confirm second character is a valid digit (necessary for octal numbers)
    exists(literalText.charAt(1).toInt()) and
    // Filter out common file permission patterns based on string length
    not literalText.length() in [4, 5, 7]
  )
}

// Find all integer literals using the ambiguous legacy octal format
from IntegerLiteral legacyOctalLiteral
where uses_legacy_octal_notation(legacyOctalLiteral)
select legacyOctalLiteral, "Confusing octal literal, use 0o" + legacyOctalLiteral.getText().suffix(1) + " instead."