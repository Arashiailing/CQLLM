/**
 * @name Unsupported format character
 * @description Detects unsupported format characters in Python percent-style format strings
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/percent-format/unsupported-character
 */

import python
import semmle.python.strings

// Identify expressions containing invalid format specifiers
from Expr formatExpr, int errorIndex
where 
  // Locate the position of illegal conversion specifier
  errorIndex = illegal_conversion_specifier(formatExpr)
select 
  formatExpr, 
  // Generate detailed error message with position information
  "Invalid conversion specifier at index " + errorIndex + " of " + repr(formatExpr) + "."