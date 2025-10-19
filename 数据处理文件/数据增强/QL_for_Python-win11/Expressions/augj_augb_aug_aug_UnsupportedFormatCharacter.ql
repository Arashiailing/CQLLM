/**
 * @name Unsupported format character
 * @description Detects Python format strings with illegal conversion specifiers
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

// Identify format expressions containing invalid conversion specifiers
from Expr formatStringExpr
where 
  // Locate the position of the illegal conversion specifier
  exists(int badSpecifierIndex | 
    badSpecifierIndex = illegal_conversion_specifier(formatStringExpr) and
    badSpecifierIndex != -1  // Only consider actual invalid specifiers
  )
select 
  formatStringExpr, 
  ("Invalid conversion specifier at index " + 
   max(int badSpecifierIndex | badSpecifierIndex = illegal_conversion_specifier(formatStringExpr)) + 
   " in format string: " + repr(formatStringExpr) + ".")