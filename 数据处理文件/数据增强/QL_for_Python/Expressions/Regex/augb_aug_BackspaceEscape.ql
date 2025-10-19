/**
 * @name Ambiguous backspace escape in regex character set
 * @description Using '\b' inside character sets to represent backspace is confusing
 *              as it conflicts with the common word boundary assertion meaning.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/regex/backspace-escape
 */

import python
import semmle.python.regex

from RegExp regExpr, int escapePos
where
  // Locate escape character at current position
  regExpr.escapingChar(escapePos) and
  // Verify 'b' follows the escape character
  regExpr.getChar(escapePos + 1) = "b" and
  // Confirm position is within a character set context
  exists(int charSetStartPos, int charSetEndPos |
    charSetStartPos < escapePos and 
    charSetEndPos > escapePos and
    regExpr.charSet(charSetStartPos, charSetEndPos)
  )
select regExpr, "Ambiguous backspace escape in character set at offset " + escapePos + "."