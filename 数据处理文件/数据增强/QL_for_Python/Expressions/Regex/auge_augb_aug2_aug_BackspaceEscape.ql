/**
 * @name Regex Backspace Escape Confusion
 * @description Identifies potentially confusing usage of '\b' escape sequence within regex character sets,
 *              where it might be interpreted as word boundary instead of backspace character.
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
  // Verify position contains an escape character (backslash)
  regexExpr.escapingChar(escapePos) and
  // Confirm the character following backslash is 'b'
  regexExpr.getChar(escapePos + 1) = "b" and
  // Ensure escape sequence is inside a character set
  exists(int setStart, int setEnd |
    setStart < escapePos and 
    setEnd > escapePos and
    regexExpr.charSet(setStart, setEnd)
  )
select regexExpr, "Backspace escape in regular expression at offset " + escapePos + "."