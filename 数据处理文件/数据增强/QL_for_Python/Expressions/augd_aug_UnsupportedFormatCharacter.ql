/**
 * @name Unsupported format character
 * @description Detects unsupported format characters in Python format strings
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

// Identify format string expressions containing invalid conversion specifiers
from Expr formatStringExpr, int badSpecifierIndex
where 
  // Calculate position of illegal format specifier in the string
  badSpecifierIndex = illegal_conversion_specifier(formatStringExpr)
select 
  formatStringExpr, 
  "Invalid conversion specifier at index " + badSpecifierIndex + 
  " in format string: " + repr(formatStringExpr) + "."