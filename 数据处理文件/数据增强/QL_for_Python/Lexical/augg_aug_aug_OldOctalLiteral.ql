/**
 * @name Ambiguous octal literal notation
 * @description Detects octal literals written with legacy notation (leading 0) which can be confused with decimal numbers
 * @kind problem
 * @tags readability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision high
 * @id py/old-style-octal-literal
 */

import python

/**
 * Finds integer literals that use the old octal format (starting with 0 but not 0o)
 * This format is confusing because it looks like decimal but is interpreted as octal
 * Exceptions: "00" and typical file permission codes (with lengths 4, 5, or 7)
 */
predicate is_old_octal(IntegerLiteral ambiguousOctalLiteral) {
  exists(string textValue | textValue = ambiguousOctalLiteral.getText() |
    // Check basic octal format requirements
    textValue.charAt(0) = "0" and
    exists(textValue.charAt(1).toInt()) and
    // Apply exclusions for special cases
    not textValue = "00" and
    // Exclude common file permission patterns based on their length
    not (exists(int contentLength | contentLength = textValue.length() |
        contentLength = 4 or
        contentLength = 5 or
        contentLength = 7
      ))
  )
}

// Find all integer literals that use the confusing legacy octal notation
from IntegerLiteral ambiguousOctalLiteral
where is_old_octal(ambiguousOctalLiteral)
select ambiguousOctalLiteral, "Ambiguous octal literal, use 0o" + ambiguousOctalLiteral.getText().suffix(1) + " instead."