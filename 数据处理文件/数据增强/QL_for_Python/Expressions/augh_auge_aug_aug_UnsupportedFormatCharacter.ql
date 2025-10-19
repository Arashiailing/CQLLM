/**
 * @name Unsupported format character
 * @description Identifies Python format strings containing invalid conversion specifiers
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/percent-format/unsupported-character
 */

// Import core Python analysis modules
import python
// Import string processing utilities
import semmle.python.strings

// Locate format string expressions with problematic conversion specifiers
from Expr formatStrExpr, int invalidSpecPos
where 
  // Calculate position of invalid conversion specifier
  invalidSpecPos = illegal_conversion_specifier(formatStrExpr)
select 
  formatStrExpr, 
  "Invalid conversion specifier detected at position " + invalidSpecPos + 
  " in format string: " + repr(formatStrExpr) + "."