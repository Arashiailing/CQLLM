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

// Predicate to identify old-style octal literals that could be misinterpreted as decimal values
// These literals start with '0', have a digit as the second character, are not '00',
// and are not typical file permission masks (length 4, 5, or 7)
predicate is_old_octal(IntegerLiteral confusingOctalLiteral) {
  exists(string literalValue, int literalLength | 
    literalValue = confusingOctalLiteral.getText() and
    literalLength = literalValue.length() and
    // Verify the literal follows old-style octal format
    literalValue.charAt(0) = "0" and
    not literalValue = "00" and
    exists(literalValue.charAt(1).toInt()) and
    // Exclude literals that are likely file permission masks
    literalLength != 4 and literalLength != 5 and literalLength != 7
  )
}

// Query for all integer literals that use the confusing old-style octal notation
from IntegerLiteral confusingOctalLiteral
where is_old_octal(confusingOctalLiteral)
select confusingOctalLiteral, "Confusing octal literal, use 0o" + confusingOctalLiteral.getText().suffix(1) + " instead."