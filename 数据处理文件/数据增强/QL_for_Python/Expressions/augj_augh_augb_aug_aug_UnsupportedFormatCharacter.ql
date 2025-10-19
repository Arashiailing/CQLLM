/**
 * @name Unsupported format character
 * @description Identifies Python format strings containing invalid conversion specifiers
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

// Find format expressions with problematic conversion specifiers
from Expr targetExpr, int violationPosition
where 
  // Locate the exact position of the invalid conversion specifier
  exists(int badPos | 
    badPos = illegal_conversion_specifier(targetExpr) and 
    violationPosition = badPos
  )
select 
  targetExpr, 
  ("Invalid conversion specifier at index " + violationPosition + 
   " in format string: " + repr(targetExpr) + ".")