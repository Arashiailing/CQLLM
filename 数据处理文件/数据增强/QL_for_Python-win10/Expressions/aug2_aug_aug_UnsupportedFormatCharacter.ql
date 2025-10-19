/**
 * @name Unsupported format character
 * @description Detects Python format strings containing illegal conversion specifiers
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

// Identify expressions with invalid format specifiers
from Expr formatString, int badIndex
where 
  // Determine position of the illegal conversion specifier
  badIndex = illegal_conversion_specifier(formatString)
select 
  formatString, 
  "Invalid conversion specifier at index " + badIndex + 
  " in format string: " + repr(formatString) + "."