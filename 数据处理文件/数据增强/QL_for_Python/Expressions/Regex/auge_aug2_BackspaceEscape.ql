/**
 * @name Backspace escape in regular expression
 * @description Detects the use of '\b' to escape the backspace character in regular expressions,
 *              which is confusing as it could be mistaken for a word boundary assertion.
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
  // Find a backslash character that serves as an escape at the given position
  regexPattern.escapingChar(backslashPos) and
  // Check if the character immediately following the backslash is 'b'
  regexPattern.getChar(backslashPos + 1) = "b" and
  // Verify this escape sequence is contained within a character set definition
  exists(int charSetStart, int charSetEnd | 
    regexPattern.charSet(charSetStart, charSetEnd) and
    charSetStart < backslashPos and 
    charSetEnd > backslashPos
  )
select regexPattern, "Backspace escape in regular expression at offset " + backslashPos + "."