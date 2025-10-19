/**
 * @name Backspace escape in regular expression
 * @description Detects usage of '\b' escape sequence within regex character sets,
 *              where it represents a backspace character rather than the typical
 *              word boundary assertion, potentially causing confusion.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/regex/backspace-escape
 */

import python
import semmle.python.regex

from RegExp regexPattern, int backslashPosition
where
  // Identify backslash escape character followed by 'b'
  regexPattern.escapingChar(backslashPosition) and
  regexPattern.getChar(backslashPosition + 1) = "b" and
  // Verify the escape sequence occurs within a character set
  exists(int charSetStartPos, int charSetEndPos | 
    charSetStartPos < backslashPosition and 
    charSetEndPos > backslashPosition and 
    regexPattern.charSet(charSetStartPos, charSetEndPos)
  )
select regexPattern, "Backspace escape in regular expression at offset " + backslashPosition + "."