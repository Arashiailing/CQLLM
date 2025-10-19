/**
 * @name Unsupported format character
 * @description Detects expressions containing invalid format specifiers
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/percent-format/unsupported-character
 */

// Import core Python analysis module
import python
// Import string manipulation utilities
import semmle.python.strings

// Query definition: identifies expressions with invalid format specifiers
from Expr exprWithFormat, int invalidCharPos
// Condition: locate the position of invalid format specifiers within the expression
where invalidCharPos = illegal_conversion_specifier(exprWithFormat)
// Output: return the expression and detailed error position information
select exprWithFormat, "Invalid conversion specifier at index " + invalidCharPos + " of " + repr(exprWithFormat) + "."