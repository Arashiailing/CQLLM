/**
 * @name Confusing backspace escape in regular expression
 * @description Using '\b' to represent backspace in regex character sets is error-prone,
 *              as it conflicts with the word boundary assertion '\b' outside character sets.
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
  // Verify 'b' follows immediately after the backslash
  regexPattern.getChar(backslashPos + 1) = "b" and
  // Confirm escape sequence is inside a character set
  exists(int charSetStartPos, int charSetEndPos |
    charSetStartPos < backslashPos and 
    charSetEndPos > backslashPos and
    regexPattern.charSet(charSetStartPos, charSetEndPos)
  )
select regexPattern, "Ambiguous backspace escape at offset " + backslashPos + " (conflicts with word boundary assertion)."