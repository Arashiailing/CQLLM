/**
 * @name Backspace escape in regular expression
 * @description Identifies instances where the backspace escape sequence '\b' is used within
 *              regex character sets. This is problematic because '\b' inside [...] represents
 *              a backspace character, while outside it denotes a word boundary, leading to
 *              potential confusion and bugs.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/regex/backspace-escape
 */

import python
import semmle.python.regex

from RegExp regexExpr, int escapePos
where
  // Verify we have a '\b' escape sequence
  regexExpr.escapingChar(escapePos) and
  regexExpr.getChar(escapePos + 1) = "b" and
  // Check if this sequence is within any character set
  exists(int setStart, int setEnd | 
    regexExpr.charSet(setStart, setEnd) and
    escapePos > setStart and 
    escapePos < setEnd
  )
select regexExpr, "Backspace escape in regular expression at offset " + escapePos + "."