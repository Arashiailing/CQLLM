/**
 * @name Backspace escape in regular expression
 * @description Detects confusing use of '\b' for backspace escape in regex character sets,
 *              which could be misinterpreted as word boundary assertion.
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
  // Locate escape character (backslash) at current position
  pattern.escapingChar(escapePos) and
  // Verify 'b' character immediately follows the escape
  pattern.getChar(escapePos + 1) = "b" and
  // Confirm the escape sequence occurs within a character set context
  exists(int setStart, int setEnd |
    setStart < escapePos and 
    setEnd > escapePos and
    pattern.charSet(setStart, setEnd)
  )
select pattern, "Backspace escape in regular expression at offset " + escapePos + "."