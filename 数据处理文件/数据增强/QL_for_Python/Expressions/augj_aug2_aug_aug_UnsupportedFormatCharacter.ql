/**
 * @name Unsupported format character
 * @description Identifies Python format strings containing illegal conversion specifiers
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

// Detect format expressions with invalid conversion specifiers
from Expr formatExpr, int invalidIndex
where 
  // Calculate position of the illegal conversion specifier
  invalidIndex = illegal_conversion_specifier(formatExpr)
select 
  formatExpr, 
  "Illegal conversion specifier at position " + invalidIndex + 
  " in format string: " + repr(formatExpr) + "."