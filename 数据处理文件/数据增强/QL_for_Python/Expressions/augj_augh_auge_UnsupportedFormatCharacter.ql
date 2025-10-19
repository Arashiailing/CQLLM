/**
 * @name Unsupported format character
 * @description Identifies Python format strings containing unsupported conversion specifiers.
 *              This analysis targets expressions with invalid format characters that could
 *              lead to runtime exceptions or produce incorrect output when formatted.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/percent-format/unsupported-character
 */

// Import core Python analysis capabilities
import python
// Import string processing utilities for format string validation
import semmle.python.strings

// Main query to locate format expressions with invalid conversion specifiers
from Expr invalidFormatString, int errorPosition
// Find expressions containing illegal conversion specifiers and capture their positions
where errorPosition = illegal_conversion_specifier(invalidFormatString)
// Generate alert message with expression details and error location
select invalidFormatString, "Invalid conversion specifier at index " + errorPosition + " of " + repr(invalidFormatString) + "."