/**
 * @name Confusing octal literal
 * @description Identifies octal literals using legacy notation (leading zero)
 *              that can be mistaken for decimal values
 * @kind problem
 * @tags readability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision high
 * @id py/old-style-octal-literal
 */

import python

// Helper predicate to detect legacy octal literals that might cause confusion
// These literals begin with '0', have a digit as the second character, are not '00',
// and don't match common file permission mask patterns (lengths 4, 5, or 7)
predicate is_legacy_octal(IntegerLiteral oldOctalLiteral) {
  exists(string numText, int valueLength | 
    numText = oldOctalLiteral.getText() and
    valueLength = numText.length() and
    // Verify basic octal format: starts with '0', followed by a digit
    numText.charAt(0) = "0" and
    not numText = "00" and
    exists(numText.charAt(1).toInt()) and
    // Filter out common file permission mask lengths
    valueLength != 4 and valueLength != 5 and valueLength != 7
  )
}

// Find all integer literals using the confusing legacy octal notation
from IntegerLiteral oldOctalLiteral
where is_legacy_octal(oldOctalLiteral)
select oldOctalLiteral, "Confusing octal literal, use 0o" + oldOctalLiteral.getText().suffix(1) + " instead."