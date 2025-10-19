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
 * Identifies integer literals using legacy octal notation (leading 0 without 0o prefix)
 * This format is problematic as it appears similar to decimal numbers but has different interpretation
 * Excluded patterns: 
 *   - Special case "00" 
 *   - Typical file permission codes (strings with length 4, 5, or 7)
 */
predicate is_old_octal(IntegerLiteral confusingOctalLiteral) {
  exists(string literalText | 
    literalText = confusingOctalLiteral.getText() and
    // Check if literal starts with '0' indicating potential octal notation
    literalText.charAt(0) = "0" and
    // Exclude the special case "00"
    not literalText = "00" and
    // Verify second character is a valid digit (required for octal numbers)
    exists(literalText.charAt(1).toInt()) and
    // Exclude common file permission patterns based on string length
    not literalText.length() in [4, 5, 7]
  )
}

// Identify all integer literals that use the ambiguous legacy octal format
from IntegerLiteral confusingOctalLiteral
where is_old_octal(confusingOctalLiteral)
select confusingOctalLiteral, "Confusing octal literal, use 0o" + confusingOctalLiteral.getText().suffix(1) + " instead."