/**
 * @name Backspace escape in regular expression
 * @description Detects the use of '\b' within character sets in regular expressions,
 *              which represents a backspace character and can be confused with the
 *              word boundary assertion when used outside character sets.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/regex/backspace-escape
 */

import python
import semmle.python.regex

from RegExp regexPattern, int escapeCharPosition
where
  // Locate the position of an escape character in the regex pattern
  regexPattern.escapingChar(escapeCharPosition) and
  // Check if the character following the escape is 'b', forming '\b'
  regexPattern.getChar(escapeCharPosition + 1) = "b" and
  // Verify this escape sequence occurs within a character set [ ... ]
  exists(int charSetStart, int charSetEnd |
    charSetStart < escapeCharPosition and 
    charSetEnd > escapeCharPosition and
    regexPattern.charSet(charSetStart, charSetEnd)
  )
select regexPattern, "Backspace escape in regular expression at offset " + escapeCharPosition + "."