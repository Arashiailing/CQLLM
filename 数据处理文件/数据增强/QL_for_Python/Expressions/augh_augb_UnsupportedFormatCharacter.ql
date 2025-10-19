/**
 * @name Unsupported format character
 * @description Identifies invalid conversion specifiers in Python percent-style format strings
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

// Find expressions with illegal percent-style format specifiers
from Expr percentFormatExpr, int invalidIndex
where 
  // Determine position of invalid conversion specifier
  invalidIndex = illegal_conversion_specifier(percentFormatExpr)
select 
  percentFormatExpr, 
  // Generate contextual error message with location details
  "Invalid conversion specifier at position " + invalidIndex + " in format string " + repr(percentFormatExpr) + "."