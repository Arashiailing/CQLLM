/**
 * @name Unsupported format character
 * @description Detects Python format strings containing invalid conversion specifiers
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

// Identify expressions with malformed format specifiers
from Expr formatExpr, int badCharIndex
where 
  // Determine location of problematic conversion specifier
  badCharIndex = illegal_conversion_specifier(formatExpr)
select 
  formatExpr, 
  "Invalid conversion specifier at index " + badCharIndex + 
  " in format string: " + repr(formatExpr) + "."