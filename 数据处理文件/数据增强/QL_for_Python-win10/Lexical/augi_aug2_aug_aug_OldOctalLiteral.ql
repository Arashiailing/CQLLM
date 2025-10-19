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
 * Identifies integer literals using legacy octal notation (leading 0 without 0o prefix).
 * This notation is confusing as it looks like decimal numbers but has different interpretation.
 * Excludes patterns: "00" and common file permission codes (length 4, 5, or 7).
 */
predicate is_legacy_octal_literal(IntegerLiteral octalLiteral) {
  exists(string literalText | 
    literalText = octalLiteral.getText() and
    // Check if literal starts with '0' indicating potential octal notation
    literalText.charAt(0) = "0" and
    // Exclude the special case "00"
    not literalText = "00" and
    // Exclude common file permission patterns based on string length
    not literalText.length() in [4, 5, 7] and
    // Ensure second character is a valid digit (required for octal numbers)
    exists(literalText.charAt(1).toInt())
  )
}

// Find all integer literals that use the confusing legacy octal format
from IntegerLiteral octalLiteral
where is_legacy_octal_literal(octalLiteral)
select octalLiteral, "Confusing octal literal, use 0o" + octalLiteral.getText().suffix(1) + " instead."