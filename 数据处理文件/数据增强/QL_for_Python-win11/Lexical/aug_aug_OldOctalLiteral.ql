/**
 * @name Confusing octal literal
 * @description Octal literal with a leading 0 is easily misread as a decimal value
 * @kind problem
 * @tags readability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision high
 * @id py/old-style-octal-literal
 */

import python

/**
 * Identifies integer literals using legacy octal notation (leading 0 without 0o prefix)
 * This notation is error-prone as it can be mistaken for decimal values
 * Exclusions: "00" and common file permission masks (length 4, 5, or 7)
 */
predicate is_old_octal(IntegerLiteral legacyOctalLiteral) {
  exists(string literalText | literalText = legacyOctalLiteral.getText() |
    // Must start with '0' to qualify as octal notation
    literalText.charAt(0) = "0" and
    // Exclude special case "00"
    not literalText = "00" and
    // Verify second character is a digit (valid octal requirement)
    exists(literalText.charAt(1).toInt()) and
    // Filter out common file permission masks by length
    exists(int textLength | textLength = literalText.length() |
      textLength != 4 and
      textLength != 5 and
      textLength != 7
    )
  )
}

// Identify all integer literals using ambiguous legacy octal notation
from IntegerLiteral legacyOctalLiteral
where is_old_octal(legacyOctalLiteral)
select legacyOctalLiteral, "Confusing octal literal, use 0o" + legacyOctalLiteral.getText().suffix(1) + " instead."