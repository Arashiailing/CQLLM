/**
 * @name Confusing octal literal
 * @description Detects octal literals using legacy notation (leading zero) which can be mistaken for decimal values
 * @kind problem
 * @tags readability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision high
 * @id py/old-style-octal-literal
 */

import python

// Determines if an integer literal uses legacy octal notation (starts with 0)
predicate isLegacyOctalLiteral(IntegerLiteral intLiteral) {
  exists(string literalValue | literalValue = intLiteral.getText() |
    // Check if literal starts with '0', excluding the special case of "00"
    literalValue.charAt(0) = "0" and
    not literalValue = "00" and
    
    // Verify the second character is a digit (indicating a valid octal number)
    exists(literalValue.charAt(1).toInt()) and
    
    /* Exclude common file permission mask patterns */
    // Check that the text length doesn't match typical file permission mask lengths (4, 5, or 7)
    exists(int valueLength | valueLength = literalValue.length() |
      valueLength != 4 and
      valueLength != 5 and
      valueLength != 7
    )
  )
}

// Find all integer literals using legacy octal notation
from IntegerLiteral intLiteral
where isLegacyOctalLiteral(intLiteral)
select intLiteral, "Confusing octal literal, use 0o" + intLiteral.getText().suffix(1) + " instead."