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

// Find expressions with invalid format specifiers
from Expr formatStringExpr, int invalidSpecifierIndex
where 
  // Calculate position of the invalid conversion specifier
  invalidSpecifierIndex = illegal_conversion_specifier(formatStringExpr)
select 
  formatStringExpr, 
  "Invalid conversion specifier at index " + invalidSpecifierIndex + 
  " in format string: " + repr(formatStringExpr) + "."