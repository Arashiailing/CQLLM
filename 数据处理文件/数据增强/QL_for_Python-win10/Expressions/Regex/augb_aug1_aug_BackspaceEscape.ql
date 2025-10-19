/**
 * @name Backspace escape in regular expression
 * @description Using '\b' to escape the backspace character in a regular expression is confusing
 *              since it could be mistaken for a word boundary assertion.
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
  // Identify escape character at current position
  regexPattern.escapingChar(backslashPos) and
  // Verify 'b' follows the escape character
  regexPattern.getChar(backslashPos + 1) = "b" and
  // Confirm escape occurs within character set boundaries
  exists(int charSetBegin, int charSetFinish |
    charSetBegin < backslashPos and 
    charSetFinish > backslashPos and
    regexPattern.charSet(charSetBegin, charSetFinish)
  )
select regexPattern, "Backspace escape in regular expression at offset " + backslashPos + "."