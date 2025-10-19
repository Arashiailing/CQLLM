/**
 * @name Backspace escape in regular expression
 * @description Identifies instances where '\b' is used within regex character sets to represent
 *              a backspace character, which can be mistaken for the word boundary assertion '\b'.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/regex/backspace-escape
 */

import python
import semmle.python.regex

from RegExp regexPattern, int escapePos
where
  // First verify the escape sequence is inside a character set [...]
  exists(int setStartPos, int setEndPos | 
    setStartPos < escapePos and 
    setEndPos > escapePos and 
    regexPattern.charSet(setStartPos, setEndPos)
  ) and
  // Then identify the escape backslash character at the specified position
  regexPattern.escapingChar(escapePos) and
  // Finally confirm the character following the escape is 'b', forming '\b'
  regexPattern.getChar(escapePos + 1) = "b"
select regexPattern, "Backspace escape in regular expression at offset " + escapePos + "."