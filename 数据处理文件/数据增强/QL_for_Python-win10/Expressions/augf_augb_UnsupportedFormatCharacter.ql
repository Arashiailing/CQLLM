/**
 * @name Unsupported format character
 * @description Identifies Python percent-style format strings containing invalid conversion specifiers
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

// Locate expressions with problematic format specifiers
from Expr formattedString, int invalidCharIndex
where 
  // Determine the exact position of the illegal conversion specifier
  invalidCharIndex = illegal_conversion_specifier(formattedString)
select 
  formattedString, 
  // Construct detailed error message with positional context
  "Invalid conversion specifier at index " + invalidCharIndex + " of " + repr(formattedString) + "."