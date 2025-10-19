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

from RegExp regex, int pos
where
  // Identify escape character at current position
  regex.escapingChar(pos) and
  // Verify 'b' character follows the escape
  regex.getChar(pos + 1) = "b" and
  // Confirm escape occurs within a character set context
  exists(int charSetStart, int charSetEnd |
    charSetStart < pos and charSetEnd > pos and
    regex.charSet(charSetStart, charSetEnd)
  )
select regex, "Backspace escape in regular expression at offset " + pos + "."