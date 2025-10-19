/**
 * @name Unsupported format character
 * @description Identifies Python format strings containing illegal conversion specifiers
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

// Identify format string expressions that contain invalid conversion specifiers
from Expr problematicFormatStr, int errorPosition
where 
  // Determine the exact position of the illegal conversion specifier within the format string
  exists(int pos | 
    pos = illegal_conversion_specifier(problematicFormatStr) and 
    errorPosition = pos
  )
select 
  problematicFormatStr, 
  "Invalid conversion specifier at index " + errorPosition + 
  " in format string: " + repr(problematicFormatStr) + "."