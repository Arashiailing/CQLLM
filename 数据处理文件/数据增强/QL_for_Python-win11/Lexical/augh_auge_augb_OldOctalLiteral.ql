/**
 * @name Confusing octal literal
 * @description Identifies old-style octal literals (leading zero) that may be 
 *              misinterpreted as decimal values due to ambiguous notation
 * @kind problem
 * @tags readability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision high
 * @id py/old-style-octal-literal
 */

import python

// Detects old-style octal literals that could be confused with decimals
// Excludes '00' and common file permission mask lengths (4,5,7)
predicate is_old_octal(IntegerLiteral confusingOctalLiteral) {
  exists(string octalText, int textLength | 
    octalText = confusingOctalLiteral.getText() and
    textLength = octalText.length() and
    // Core octal format checks
    octalText.charAt(0) = "0" and
    not octalText = "00" and
    exists(octalText.charAt(1).toInt()) and
    // Exclude likely file permission masks
    textLength != 4 and textLength != 5 and textLength != 7
  )
}

// Find all integer literals using confusing old-style octal notation
from IntegerLiteral confusingOctalLiteral
where is_old_octal(confusingOctalLiteral)
select confusingOctalLiteral, "Confusing octal literal, use 0o" + confusingOctalLiteral.getText().suffix(1) + " instead."