/**
 * @name Confusing octal literal
 * @description Octal literals with a leading zero (without the '0o' prefix) can be easily misread as decimal numbers. This query identifies such literals, excluding common cases like '00' and file permission representations.
 * @kind problem
 * @tags readability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision high
 * @id py/old-style-octal-literal
 */

import python

/**
 * Holds if the given integer literal uses the legacy octal notation (a leading zero without the '0o' prefix).
 * Such literals are confusing because they look like decimal numbers but represent octal values.
 * We exclude the literal "00" and literals that are likely file permission representations (with lengths 4, 5, or 7).
 */
predicate uses_legacy_octal_notation(IntegerLiteral confusingLiteral) {
  exists(string literalValue | 
    literalValue = confusingLiteral.getText() and
    // Must start with '0' to indicate potential octal notation
    literalValue.charAt(0) = "0" and
    // Ensure there's at least one digit following the leading zero
    literalValue.length() > 1 and
    // Second character must be a valid octal digit (0-7)
    literalValue.charAt(1) in ["0","1","2","3","4","5","6","7"] and
    // Exclude the special case "00"
    not literalValue = "00" and
    // Filter out common file permission patterns based on string length
    not literalValue.length() in [4, 5, 7]
  )
}

// Identify all integer literals using the ambiguous legacy octal format
from IntegerLiteral confusingLiteral
where uses_legacy_octal_notation(confusingLiteral)
select confusingLiteral, "Confusing octal literal, use 0o" + confusingLiteral.getText().suffix(1) + " instead."