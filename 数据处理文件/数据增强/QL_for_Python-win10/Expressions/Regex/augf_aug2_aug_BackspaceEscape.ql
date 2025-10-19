/**
 * @name Backspace escape in regular expression
 * @description Identifies potentially confusing use of '\b' inside regex character classes,
 *              where it might be intended as backspace but could be interpreted as word boundary.
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
  // Check if current position contains an escape character (backslash)
  regexPattern.escapingChar(backslashPosition) and
  // Verify that 'b' character follows immediately after the backslash
  regexPattern.getChar(backslashPosition + 1) = "b" and
  // Ensure this escape sequence is contained within a character set
  exists(int charSetStart, int charSetEnd |
    // Character set boundaries must encompass the escape sequence
    charSetStart < backslashPosition and 
    charSetEnd > backslashPosition and
    // Confirm the range represents a valid character set
    regexPattern.charSet(charSetStart, charSetEnd)
  )
select regexPattern, "Backspace escape in regular expression at offset " + backslashPosition + "."