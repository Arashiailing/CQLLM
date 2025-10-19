/**
 * @name Confusing octal literal
 * @description Detects octal literals with leading zero that can be misread as decimal values
 * @kind problem
 * @tags readability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision high
 * @id py/old-style-octal-literal
 */

import python

/**
 * Finds integer literals that use legacy octal notation (starting with 0 but without 0o prefix).
 * This notation is confusing because it looks like decimal but is interpreted as octal.
 * Excludes: "00" and common file permission masks (with lengths 4, 5, or 7).
 */
predicate is_old_octal(IntegerLiteral confusingOctalLiteral) {
  exists(string textValue | textValue = confusingOctalLiteral.getText() |
    // Must start with '0' to qualify as octal notation
    textValue.charAt(0) = "0" and
    // Exclude special case "00"
    not textValue = "00" and
    // Verify second character is a digit (valid octal requirement)
    exists(textValue.charAt(1).toInt()) and
    // Filter out common file permission masks by length
    exists(int strLength | strLength = textValue.length() |
      strLength != 4 and
      strLength != 5 and
      strLength != 7
    )
  )
}

// Locate all integer literals that use the confusing legacy octal notation
from IntegerLiteral confusingOctalLiteral
where is_old_octal(confusingOctalLiteral)
select confusingOctalLiteral, "Confusing octal literal, use 0o" + confusingOctalLiteral.getText().suffix(1) + " instead."