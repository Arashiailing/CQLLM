/**
 * @name Unsupported format specifier
 * @description Identifies unsupported format specifiers in Python format strings
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/percent-format/unsupported-character
 */

// Core Python analysis imports
import python
// String processing utilities
import semmle.python.strings

// Locate expressions containing invalid format specifiers
from Expr fmtExpr, int invalidIndex
where 
  // Determine position of illegal conversion specifier
  invalidIndex = illegal_conversion_specifier(fmtExpr)
select 
  fmtExpr, 
  "Invalid conversion specifier at index " + invalidIndex + 
  " in format string: " + repr(fmtExpr) + "."