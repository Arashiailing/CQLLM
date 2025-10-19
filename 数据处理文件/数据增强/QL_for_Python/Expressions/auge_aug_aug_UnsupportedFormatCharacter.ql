/**
 * @name Unsupported format character
 * @description Detects Python format strings that use illegal conversion specifiers
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/percent-format/unsupported-character
 */

// Import essential Python analysis modules
import python
// Import string manipulation utilities
import semmle.python.strings

// Identify format string expressions with invalid conversion specifiers
from Expr formattedStringExpr, int badSpecifierPos
where 
  // Determine the position of the problematic conversion specifier
  badSpecifierPos = illegal_conversion_specifier(formattedStringExpr)
select 
  formattedStringExpr, 
  "Illegal conversion specifier found at position " + badSpecifierPos + 
  " in format string: " + repr(formattedStringExpr) + "."