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
 * Detects integer literals that use outdated octal notation (leading 0 without 0o prefix)
 * This format is confusing as it resembles decimal numbers but has different interpretation
 * Excluded patterns: "00" and typical file permission codes (length 4, 5, or 7)
 */
predicate is_old_octal(IntegerLiteral ambiguousOctalLiteral) {
  exists(string octalString | 
    octalString = ambiguousOctalLiteral.getText() and
    // Check if literal starts with '0' indicating potential octal notation
    octalString.charAt(0) = "0" and
    // Exclude the special case "00"
    not octalString = "00" and
    // Ensure second character is a valid digit (required for octal numbers)
    exists(octalString.charAt(1).toInt()) and
    // Exclude common file permission patterns based on string length
    not octalString.length() in [4, 5, 7]
  )
}

// Locate all integer literals that use the ambiguous legacy octal format
from IntegerLiteral ambiguousOctalLiteral
where is_old_octal(ambiguousOctalLiteral)
select ambiguousOctalLiteral, "Confusing octal literal, use 0o" + ambiguousOctalLiteral.getText().suffix(1) + " instead."