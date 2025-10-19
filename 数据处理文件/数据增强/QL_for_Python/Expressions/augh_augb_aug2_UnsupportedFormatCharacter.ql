/**
 * @name Unsupported format character
 * @description Identifies invalid conversion specifiers in percent-style format strings
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/percent-format/unsupported-character
 */

// Import core Python analysis framework
import python
// Import string analysis utilities for format validation
import semmle.python.strings

// Identify format expressions with invalid conversion specifiers
from Expr formatStringExpr, int invalidIndex
// Validate conversion specifier legality
where invalidIndex = illegal_conversion_specifier(formatStringExpr)
// Report expressions with problematic format specifiers
select formatStringExpr, "Invalid conversion specifier at position " + invalidIndex + " in format string: " + repr(formatStringExpr) + "."