/**
 * @name Confusing octal literal
 * @description Detects octal literals using the old-style notation (leading zero without '0o' prefix) which can be misinterpreted as decimal numbers. This query flags such literals while excluding common cases like '00' and file permission representations.
 * @kind problem
 * @tags readability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision high
 * @id py/old-style-octal-literal
 */

import python

/**
 * Determines if an integer literal employs the outdated octal format (starting with zero but lacking the '0o' prefix).
 * These literals are problematic as they resemble decimal numbers but actually represent octal values.
 * The check excludes "00" and literals that typically represent file permissions (with lengths of 4, 5, or 7 characters).
 */
predicate employs_legacy_octal_format(IntegerLiteral legacyOctalLiteral) {
  exists(string literalText | 
    literalText = legacyOctalLiteral.getText() and
    // Check basic octal format: starts with '0' and has valid octal digits
    literalText.charAt(0) = "0" and
    literalText.length() > 1 and
    literalText.charAt(1) in ["0","1","2","3","4","5","6","7"] and
    // Exclude special cases that are not actually confusing
    not (literalText = "00" or literalText.length() in [4, 5, 7])
  )
}

// Find all integer literals that use the ambiguous legacy octal notation
from IntegerLiteral legacyOctalLiteral
where employs_legacy_octal_format(legacyOctalLiteral)
select legacyOctalLiteral, "Confusing octal literal, use 0o" + legacyOctalLiteral.getText().suffix(1) + " instead."