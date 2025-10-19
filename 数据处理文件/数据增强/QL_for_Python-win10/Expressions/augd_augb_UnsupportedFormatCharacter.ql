/**
 * @name Unsupported format character
 * @description Detects unsupported format characters in Python percent-style format strings.
 * This query identifies expressions containing invalid conversion specifiers that can cause runtime errors.
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

// Locate expressions with invalid conversion specifiers
from Expr formatStrExpr, int invalidIndex
where 
  // Determine position of illegal conversion specifier
  invalidIndex = illegal_conversion_specifier(formatStrExpr)
select 
  formatStrExpr, 
  // Construct detailed error message with location details
  "Invalid conversion specifier at index " + 
  invalidIndex + 
  " of " + 
  repr(formatStrExpr) + 
  "."