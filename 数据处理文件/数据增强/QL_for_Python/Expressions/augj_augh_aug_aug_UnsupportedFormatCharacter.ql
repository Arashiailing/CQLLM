/**
 * @name Unsupported format character
 * @description Identifies Python format strings that use invalid conversion specifiers
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/percent-format/unsupported-character
 */

// Import core Python analysis framework
import python
// Import utilities for string processing and analysis
import semmle.python.strings

// Find format expressions containing problematic conversion specifiers
from Expr formatStringExpr, int invalidSpecifierIndex
where 
  // Locate the position of the invalid conversion specifier
  invalidSpecifierIndex = illegal_conversion_specifier(formatStringExpr)
select 
  formatStringExpr, 
  "Invalid conversion specifier at index " + invalidSpecifierIndex + 
  " in format string: " + repr(formatStringExpr) + "."