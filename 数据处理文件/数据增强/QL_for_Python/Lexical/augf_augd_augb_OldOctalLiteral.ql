/**
 * @name Confusing octal literal
 * @description Detects integer literals using legacy octal notation (prefix '0')
 *              which may be misinterpreted as decimal values by developers
 * @kind problem
 * @tags readability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision high
 * @id py/old-style-octal-literal
 */

import python

// Predicate to identify potentially confusing legacy octal literals
// Legacy octals start with '0' followed by a digit, excluding '00'
// and common file permission patterns (lengths 4, 5, or 7)
predicate is_confusing_legacy_octal(IntegerLiteral confusingOctalLiteral) {
  exists(string literalText, int textLength | 
    literalText = confusingOctalLiteral.getText() and
    textLength = literalText.length() and
    // Check for legacy octal format: starts with '0', second char is a digit
    literalText.charAt(0) = "0" and
    not literalText = "00" and
    exists(literalText.charAt(1).toInt()) and
    // Exclude common file permission mask lengths
    textLength != 4 and textLength != 5 and textLength != 7
  )
}

// Locate all integer literals that use the confusing legacy octal notation
from IntegerLiteral confusingOctalLiteral
where is_confusing_legacy_octal(confusingOctalLiteral)
select confusingOctalLiteral, "Confusing octal literal, use 0o" + confusingOctalLiteral.getText().suffix(1) + " instead."