/**
 * @name Backspace escape in regular expression
 * @description Detects confusing use of '\b' for backspace escape in regex patterns,
 *              which conflicts with word boundary assertions.
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
  // Verify escape character at current position
  regexPattern.escapingChar(backslashPos) and
  // Confirm 'b' character follows the escape sequence
  regexPattern.getChar(backslashPos + 1) = "b" and
  // Ensure escape sequence occurs within character set boundaries
  exists(int charSetBegin, int charSetEnd |
    charSetBegin < backslashPos and charSetEnd > backslashPos and
    regexPattern.charSet(charSetBegin, charSetEnd)
  )
select regexPattern, "Backspace escape in regular expression at offset " + backslashPos + "."