/**
 * @name Regex Backspace Escape Misinterpretation
 * @description Detects ambiguous '\b' usage within regex character sets,
 *              where it could be confused with word boundary instead of backspace.
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
  // Verify escape sequence is inside a character set
  exists(int setStart, int setEnd |
    regexExpr.charSet(setStart, setEnd) and
    setStart < escapePos and 
    setEnd > escapePos
  ) and
  // Confirm current position contains backslash escape
  regexExpr.escapingChar(escapePos) and
  // Ensure following character is 'b'
  regexExpr.getChar(escapePos + 1) = "b"
select regexExpr, "Ambiguous backspace escape at offset " + escapePos + " in character set."