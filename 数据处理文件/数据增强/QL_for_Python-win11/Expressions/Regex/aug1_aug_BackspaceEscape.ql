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

from RegExp pattern, int escapePosition
where
  // Locate backslash escape character at current position
  pattern.escapingChar(escapePosition) and
  // Verify 'b' character immediately follows the escape
  pattern.getChar(escapePosition + 1) = "b" and
  // Ensure escape occurs within character set boundaries
  exists(int charSetStart, int charSetEnd |
    charSetStart < escapePosition and 
    charSetEnd > escapePosition and
    pattern.charSet(charSetStart, charSetEnd)
  )
select pattern, "Backspace escape in regular expression at offset " + escapePosition + "."