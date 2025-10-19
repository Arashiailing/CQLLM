/**
 * @name Regex Backspace Escape Confusion
 * @description Identifies potentially confusing usage of '\b' escape sequence within regex character sets,
 *              where it might be interpreted as word boundary instead of backspace character.
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
  // Check if current position contains an escape character (backslash)
  regexPattern.escapingChar(backslashPos) and
  // Verify the character following the backslash is 'b'
  regexPattern.getChar(backslashPos + 1) = "b" and
  // Ensure the escape sequence is inside a character set
  exists(int charSetStart, int charSetEnd |
    charSetStart < backslashPos and 
    charSetEnd > backslashPos and
    regexPattern.charSet(charSetStart, charSetEnd)
  )
select regexPattern, "Backspace escape in regular expression at offset " + backslashPos + "."