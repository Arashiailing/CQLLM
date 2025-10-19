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

// Identify expressions with invalid format specifiers
from Expr formatExpr, int invalidSpecifierIndex
// Match expressions containing illegal conversion specifiers
where invalidSpecifierIndex = illegal_conversion_specifier(formatExpr)
// Report expressions with invalid format specifiers
select formatExpr, "Invalid conversion specifier at index " + invalidSpecifierIndex + " of " + repr(formatExpr) + "."