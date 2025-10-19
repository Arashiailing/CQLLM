/**
 * @name Backspace escape in regular expression
 * @description Detects when '\b' is used to represent a backspace character within regex character sets,
 *              which can be confused with the word boundary assertion '\b'.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/regex/backspace-escape
 */

import python
import semmle.python.regex

from RegExp regexPattern, int backslashPos
where
  // Check for an escape character (backslash) at the specified position
  regexPattern.escapingChar(backslashPos) and
  // Verify the character following the backslash is 'b', forming '\b'
  regexPattern.getChar(backslashPos + 1) = "b" and
  // Confirm this escape sequence is contained within a character set [...]
  exists(int setStart, int setEnd | 
    setStart < backslashPos and 
    setEnd > backslashPos and 
    regexPattern.charSet(setStart, setEnd)
  )
select regexPattern, "Backspace escape in regular expression at offset " + backslashPos + "."