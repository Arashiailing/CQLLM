/**
 * @name Ambiguous octal number notation
 * @description Integer literals starting with 0 (legacy octal) can be confused with decimal values
 * @kind problem
 * @tags readability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision high
 * @id py/old-style-octal-literal
 */

import python

/**
 * Detects integer literals that use the outdated octal format (leading zero without 0o prefix)
 * This notation is confusing because it looks like a decimal but is interpreted as octal
 * Excludes "00" and typical file permission patterns (lengths 4, 5, or 7)
 */
predicate uses_legacy_octal_format(IntegerLiteral ambiguousOctalLiteral) {
  exists(string octalStringValue, int valueLength |
    octalStringValue = ambiguousOctalLiteral.getText() and
    valueLength = octalStringValue.length() and
    // Basic octal format check: starts with '0'
    octalStringValue.charAt(0) = "0" and
    // Exclude special cases
    not octalStringValue = "00" and
    // Must have a valid octal digit as second character
    exists(octalStringValue.charAt(1).toInt()) and
    // Exclude common file permission masks
    valueLength != 4 and
    valueLength != 5 and
    valueLength != 7
  )
}

// Find all integer literals that use the confusing legacy octal notation
from IntegerLiteral ambiguousOctalLiteral
where uses_legacy_octal_format(ambiguousOctalLiteral)
select ambiguousOctalLiteral, "Ambiguous octal literal, use 0o" + ambiguousOctalLiteral.getText().suffix(1) + " instead."