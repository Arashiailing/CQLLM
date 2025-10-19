/**
 * @name Unsupported format character
 * @description Detects unsupported format characters in percent-style format strings
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/percent-format/unsupported-character
 */

// Import Python analysis framework
import python
// Import string processing utilities
import semmle.python.strings

// Select expressions containing invalid format specifiers
from Expr expr, int specifierPos
// Identify positions of illegal conversion specifiers
where specifierPos = illegal_conversion_specifier(expr)
// Report expressions with invalid format specifiers
select expr, "Invalid conversion specifier at index " + specifierPos + " of " + repr(expr) + "."