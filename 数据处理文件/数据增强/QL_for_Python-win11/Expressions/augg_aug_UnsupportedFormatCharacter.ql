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

// This query identifies Python expressions containing format strings with illegal conversion specifiers
// which may lead to runtime errors or unexpected behavior during string formatting operations
from Expr formattedExpr, int errorPosition
where 
  // Locate the position of the invalid conversion specifier within the format expression
  errorPosition = illegal_conversion_specifier(formattedExpr)
select 
  formattedExpr, 
  "Invalid conversion specifier at index " + errorPosition + 
  " in format string: " + repr(formattedExpr) + "."