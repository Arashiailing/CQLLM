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

// Identify expressions with illegal format specifiers
from Expr formatExpression, int invalidPosition
where 
  // Locate the position of the invalid conversion specifier
  invalidPosition = illegal_conversion_specifier(formatExpression)
select 
  formatExpression, 
  "Invalid conversion specifier at index " + invalidPosition + 
  " in format string: " + repr(formatExpression) + "."