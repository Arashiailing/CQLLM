/**
 * @name Backspace escape in regular expression
 * @description Identifies potentially confusing use of '\b' escape sequence within regex character sets.
 *              Inside character sets, '\b' denotes a backspace character, but it may be misinterpreted
 *              as a word boundary assertion by developers, leading to unintended behavior.
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
  // Identify positions where a backslash escape character occurs
  regexPattern.escapingChar(backslashPos) and
  // Verify the character immediately following the backslash is 'b'
  regexPattern.getChar(backslashPos + 1) = "b" and
  // Confirm the escape sequence is contained within a character set
  exists(int charSetStart, int charSetEnd |
    charSetStart < backslashPos and 
    charSetEnd > backslashPos and
    regexPattern.charSet(charSetStart, charSetEnd)
  )
select regexPattern, "Backspace escape in regular expression at offset " + backslashPos + "."