/**
 * @name Ambiguous octal literal notation
 * @description Identifies integer literals using legacy octal notation (leading 0) that can be misinterpreted as decimal numbers
 * @kind problem
 * @tags readability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision high
 * @id py/old-style-octal-literal
 */

import python

/**
 * Detects integer literals with ambiguous octal notation (starting with 0 but not 0o)
 * This legacy format is problematic because it appears decimal but is interpreted as octal
 * Exclusions: "00" and common file permission patterns (lengths 4, 5, or 7)
 */
predicate is_old_octal(IntegerLiteral legacyOctalLiteral) {
  exists(string literalText | literalText = legacyOctalLiteral.getText() |
    // Verify basic octal format requirements
    literalText.charAt(0) = "0" and
    exists(literalText.charAt(1).toInt()) and
    // Apply special case exclusions
    not literalText = "00" and
    // Exclude typical file permission patterns by length
    not (literalText.length() = 4 or
         literalText.length() = 5 or
         literalText.length() = 7)
  )
}

// Locate all integer literals using the confusing legacy octal notation
from IntegerLiteral legacyOctalLiteral
where is_old_octal(legacyOctalLiteral)
select legacyOctalLiteral, "Ambiguous octal literal, use 0o" + legacyOctalLiteral.getText().suffix(1) + " instead."