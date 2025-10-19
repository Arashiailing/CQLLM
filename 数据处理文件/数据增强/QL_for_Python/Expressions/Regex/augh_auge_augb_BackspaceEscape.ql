/**
 * @name Backspace escape in regular expression
 * @description Identifies regular expressions using '\b' for backspace character,
 *              which conflicts with its common usage as word boundary assertion.
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
  // Locate backslash escape sequence followed by 'b'
  regexPattern.escapingChar(backslashPos) and
  regexPattern.getChar(backslashPos + 1) = "b" and
  // Validate escape sequence occurs within character class
  exists(int charSetStart, int charSetEnd | 
    charSetStart < backslashPos and 
    charSetEnd > backslashPos and
    regexPattern.charSet(charSetStart, charSetEnd)
  )
select regexPattern, "Backspace escape in regular expression at offset " + backslashPos + "."