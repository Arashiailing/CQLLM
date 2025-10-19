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

from RegExp regex, int offset
where
  // Check for escape character at current position
  regex.escapingChar(offset) and
  // Verify 'b' character immediately follows the escape
  regex.getChar(offset + 1) = "b" and
  // Confirm the escape sequence occurs within a character set context
  exists(int charSetBegin, int charSetEnd |
    charSetBegin < offset and charSetEnd > offset and
    regex.charSet(charSetBegin, charSetEnd)
  )
select regex, "Backspace escape in regular expression at offset " + offset + "."