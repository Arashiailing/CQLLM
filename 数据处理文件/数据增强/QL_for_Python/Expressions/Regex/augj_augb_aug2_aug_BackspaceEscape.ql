/**
 * @name Regex Backspace Escape Confusion
 * @description Detects confusing usage of '\b' within regex character sets,
 *              which could be misinterpreted as word boundary rather than backspace.
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
  // Verify that we have a '\b' escape sequence
  regexExpr.escapingChar(escapePos) and
  regexExpr.getChar(escapePos + 1) = "b" and
  // Ensure this escape sequence is inside a character set
  exists(int setStart, int setEnd |
    regexExpr.charSet(setStart, setEnd) and
    setStart < escapePos and 
    setEnd > escapePos
  )
select regexExpr, "Backspace escape in regular expression at offset " + escapePos + "."