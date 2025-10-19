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

// Identify expressions containing illegal format specifiers
from Expr formatExpr, int invalidIndex
where 
  // Calculate the position of invalid conversion specifier
  exists(int specifierPos | 
    specifierPos = illegal_conversion_specifier(formatExpr) and
    invalidIndex = specifierPos
  )
select 
  formatExpr, 
  "Invalid conversion specifier at index " + invalidIndex + 
  " in format string: " + repr(formatExpr) + "."