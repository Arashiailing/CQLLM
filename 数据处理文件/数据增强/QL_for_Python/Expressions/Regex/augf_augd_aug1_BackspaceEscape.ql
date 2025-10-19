/**
 * @name Backspace escape in regular expression
 * @description Detects confusing use of '\b' within regex character sets,
 *              where it represents backspace but resembles word boundary.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/regex/backspace-escape
 */

import python
import semmle.python.regex

from RegExp regex, int escapePos
where
  // Locate an escape backslash character at the specified position
  regex.escapingChar(escapePos) and
  // Confirm the character following the backslash is 'b', forming \b sequence
  regex.getChar(escapePos + 1) = "b" and
  // Verify the \b sequence is contained within character set brackets
  exists(int setStart, int setEnd | 
    setStart < escapePos and 
    setEnd > escapePos and 
    regex.charSet(setStart, setEnd)
  )
select regex, "Backspace escape in regular expression at offset " + escapePos + "."