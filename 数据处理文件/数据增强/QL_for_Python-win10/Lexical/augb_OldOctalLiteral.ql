/**
 * @name Confusing octal literal
 * @description Detects octal literals using the old-style notation (leading zero)
 *              which can be easily confused with decimal values
 * @kind problem
 * @tags readability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision high
 * @id py/old-style-octal-literal
 */

import python

// Predicate to identify old-style octal literals that could be misinterpreted
// These literals start with '0', have a digit as the second character, are not '00',
// and are not typical file permission masks (length 4, 5, or 7)
predicate is_old_octal(IntegerLiteral octalLiteral) {
  exists(string literalText, int textLength | 
    literalText = octalLiteral.getText() and
    textLength = literalText.length() and
    // Check basic octal format: starts with '0', has digit as second character
    literalText.charAt(0) = "0" and
    not literalText = "00" and
    exists(literalText.charAt(1).toInt()) and
    // Exclude common file permission mask lengths
    textLength != 4 and textLength != 5 and textLength != 7
  )
}

// Query for all integer literals that use the confusing old-style octal notation
from IntegerLiteral octalLiteral
where is_old_octal(octalLiteral)
select octalLiteral, "Confusing octal literal, use 0o" + octalLiteral.getText().suffix(1) + " instead."