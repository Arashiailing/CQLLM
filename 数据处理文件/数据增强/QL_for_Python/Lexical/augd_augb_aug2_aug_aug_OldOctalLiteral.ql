/**
 * @name Confusing octal literal
 * @description Detects octal literals that use the old-style notation (leading 0),
 *              which can be confusing as they appear similar to decimal numbers
 *              but have different values.
 * @kind problem
 * @tags readability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision high
 * @id py/old-style-octal-literal
 */

import python

/**
 * Identifies integer literals that use the legacy octal notation (starting with 0
 * but without the 0o prefix). This notation is confusing because it looks like a
 * decimal number but represents a different value. The predicate excludes the
 * special case "00" and common file permission representations (with lengths 4, 5, or 7).
 */
predicate uses_legacy_octal_notation(IntegerLiteral octalLiteral) {
  exists(string literalValue | 
    literalValue = octalLiteral.getText() and
    // Basic check: starts with '0' and has at least one more digit
    literalValue.charAt(0) = "0" and
    literalValue.length() > 1 and
    exists(literalValue.charAt(1).toInt()) and
    // Exclusions: not "00" and not common file permission patterns
    not literalValue = "00" and
    not literalValue.length() in [4, 5, 7]
  )
}

// Query to find all integer literals that use the confusing legacy octal format
from IntegerLiteral octalLiteral
where uses_legacy_octal_notation(octalLiteral)
select octalLiteral, "Confusing octal literal, use 0o" + octalLiteral.getText().suffix(1) + " instead."