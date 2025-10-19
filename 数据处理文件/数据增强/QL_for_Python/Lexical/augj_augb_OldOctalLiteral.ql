/**
 * @name Confusing octal literal
 * @description Identifies octal literals using legacy notation (leading zero)
 *              that may be misinterpreted as decimal values
 * @kind problem
 * @tags readability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision high
 * @id py/old-style-octal-literal
 */

import python

// Predicate to detect legacy octal literals that could cause confusion
// These literals start with '0', have a numeric second character, aren't '00',
// and don't match common file permission mask lengths (4, 5, or 7 digits)
predicate is_old_octal(IntegerLiteral confusingLiteral) {
  exists(string literalText, int textLength | 
    literalText = confusingLiteral.getText() and
    textLength = literalText.length() and
    // Verify basic octal format: starts with '0' followed by a digit
    literalText.charAt(0) = "0" and
    exists(literalText.charAt(1).toInt()) and
    // Exclude special cases
    not literalText = "00" and
    // Filter out common file permission mask lengths
    not (textLength = 4 or textLength = 5 or textLength = 7)
  )
}

// Query for integer literals using ambiguous legacy octal notation
from IntegerLiteral confusingLiteral
where is_old_octal(confusingLiteral)
select confusingLiteral, "Confusing octal literal, use 0o" + confusingLiteral.getText().suffix(1) + " instead."