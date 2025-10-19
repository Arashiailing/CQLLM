/**
 * @name Backspace escape in regular expression
 * @description Detects confusing use of '\b' in regex character sets where it represents
 *              backspace but may be misinterpreted as word boundary assertion.
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
  // Identify backslash character at current position
  regexPattern.escapingChar(backslashPos) and
  // Verify 'b' character follows immediately after backslash
  regexPattern.getChar(backslashPos + 1) = "b" and
  // Confirm escape occurs within a character set (square brackets)
  exists(int setStart, int setEnd |
    setStart < backslashPos and 
    setEnd > backslashPos and
    regexPattern.charSet(setStart, setEnd)
  )
select regexPattern, "Backspace escape in regular expression at offset " + backslashPos + "."