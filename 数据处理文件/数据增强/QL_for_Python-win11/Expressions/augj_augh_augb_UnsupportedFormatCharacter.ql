/**
 * Detects Python percent-style format strings containing invalid conversion specifiers
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

// Identify format expressions with problematic conversion specifiers
from Expr formatExpression, int specifierPosition
where 
  // Locate the position of invalid conversion specifier
  specifierPosition = illegal_conversion_specifier(formatExpression)
select 
  formatExpression, 
  // Generate detailed error message with position and expression details
  "Invalid conversion specifier at position " + specifierPosition + " in format string " + repr(formatExpression) + "."