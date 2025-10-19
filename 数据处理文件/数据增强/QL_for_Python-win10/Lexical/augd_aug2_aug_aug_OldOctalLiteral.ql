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
 * Identifies integer literals that use the legacy octal format (leading 0 without 0o prefix).
 * Such literals can be misleading as they appear decimal but are interpreted as octal.
 * Special cases like "00" and typical file permission codes (length 4, 5, or 7) are excluded.
 */
predicate uses_legacy_octal_format(IntegerLiteral legacyOctalLiteral) {
  exists(string literalText | 
    literalText = legacyOctalLiteral.getText() and
    // Verify the literal starts with '0', indicating potential octal notation
    literalText.charAt(0) = "0" and
    // Exclude the special case "00"
    not literalText = "00" and
    // Confirm the second character is a valid digit (required for octal numbers)
    exists(literalText.charAt(1).toInt()) and
    // Filter out common file permission patterns based on string length
    not literalText.length() in [4, 5, 7]
  )
}

// Find all integer literals using the confusing legacy octal notation
from IntegerLiteral legacyOctalLiteral
where uses_legacy_octal_format(legacyOctalLiteral)
select legacyOctalLiteral, "Confusing octal literal, use 0o" + legacyOctalLiteral.getText().suffix(1) + " instead."