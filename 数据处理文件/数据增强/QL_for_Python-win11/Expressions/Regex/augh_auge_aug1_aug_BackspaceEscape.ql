/**
 * @name Backspace escape in regular expression
 * @description Detects usage of '\b' to represent backspace character within regex character sets,
 *              which can be confused with word boundary assertions.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/regex/backspace-escape
 */

import python
import semmle.python.regex

from RegExp pattern, int escPos
where
  // First, locate all escape characters in the regex pattern
  pattern.escapingChar(escPos) and
  
  // Then, verify that 'b' follows the escape character, forming '\b' sequence
  pattern.getChar(escPos + 1) = "b" and
  
  // Finally, ensure this escape sequence is contained within a character set definition
  exists(int setStart, int setEnd |
    // Character set must properly enclose the escape position
    setStart < escPos and 
    setEnd > escPos and
    // Validate that these positions actually define a character set
    pattern.charSet(setStart, setEnd)
  )
select pattern, "Backspace escape in regular expression at offset " + escPos + "."