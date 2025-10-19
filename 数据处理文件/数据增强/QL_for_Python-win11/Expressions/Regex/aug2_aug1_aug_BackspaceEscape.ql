/**
 * @name Backspace escape in regular expression
 * @description The use of '\b' to represent the backspace character within a regular expression
 *              character set can be confusing, as it might be mistaken for a word boundary assertion.
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
  // Check for backslash escape character at current position
  regexPattern.escapingChar(backslashPos) and
  // Verify 'b' character immediately follows the escape
  regexPattern.getChar(backslashPos + 1) = "b" and
  // Ensure escape occurs within character set boundaries
  exists(int charSetBegin, int charSetFinish |
    charSetBegin < backslashPos and 
    charSetFinish > backslashPos and
    regexPattern.charSet(charSetBegin, charSetFinish)
  )
select regexPattern, "Backspace escape in regular expression at offset " + backslashPos + "."