/**
 * @name Unsupported format character
 * @description Detects Python format strings containing illegal conversion specifiers
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

// Identify format expressions with invalid conversion specifiers
from Expr formatStringExpr, int illegalSpecifierIndex
where 
  // Locate position of the illegal conversion specifier
  illegalSpecifierIndex = illegal_conversion_specifier(formatStringExpr)
select 
  formatStringExpr, 
  ("Invalid conversion specifier at index " + illegalSpecifierIndex + 
   " in format string: " + repr(formatStringExpr) + ".")