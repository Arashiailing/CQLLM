/**
 * @name Backspace escape in regular expression
 * @description Detects use of '\b' within character sets which represents backspace,
 *              potentially confusing developers who expect word boundary behavior.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/regex/backspace-escape
 */

import python
import semmle.python.regex

from RegExp pattern, int escapePos
where
  // Locate escape character position in pattern
  pattern.escapingChar(escapePos) and
  // Verify 'b' character follows the escape
  pattern.getChar(escapePos + 1) = "b" and
  // Confirm escape occurs within character set boundaries
  exists(int charSetStart, int charSetEnd |
    charSetStart < escapePos and 
    charSetEnd > escapePos and
    pattern.charSet(charSetStart, charSetEnd)
  )
select pattern, "Backspace escape in regular expression at offset " + escapePos + "."