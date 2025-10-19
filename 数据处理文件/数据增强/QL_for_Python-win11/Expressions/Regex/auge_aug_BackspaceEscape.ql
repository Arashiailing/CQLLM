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

from RegExp regex, int escapePos
where
  // Locate escape character at current position
  regex.escapingChar(escapePos) and
  // Verify 'b' character follows the escape sequence
  regex.getChar(escapePos + 1) = "b" and
  // Ensure escape occurs within character set boundaries
  exists(int charSetBegin, int charSetEnd |
    charSetBegin < escapePos and charSetEnd > escapePos and
    regex.charSet(charSetBegin, charSetEnd)
  )
select regex, "Backspace escape in regular expression at offset " + escapePos + "."