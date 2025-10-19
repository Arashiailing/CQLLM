/**
 * @name Unsupported format character
 * @description Identifies Python format strings that contain illegal conversion specifiers
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/percent-format/unsupported-character
 */

// Import core Python analysis capabilities
import python
// Import string analysis utilities for format string processing
import semmle.python.strings

// Find format expressions with problematic conversion specifiers
from Expr formatExpr, int errorPosition
where 
  // Locate the index of the invalid conversion specifier within the expression
  errorPosition = illegal_conversion_specifier(formatExpr)
select 
  formatExpr, 
  "Invalid conversion specifier at index " + errorPosition + 
  " in format string: " + repr(formatExpr) + "."