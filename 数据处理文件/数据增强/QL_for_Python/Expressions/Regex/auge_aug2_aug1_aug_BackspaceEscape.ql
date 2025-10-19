/**
 * @name Backspace escape in regular expression
 * @description Detects ambiguous use of '\b' within regex character sets,
 *              which could be misinterpreted as word boundary instead of backspace.
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
  // Identify character set boundaries containing the escape sequence
  exists(int setStart, int setEnd |
    setStart < escapePos and 
    setEnd > escapePos and
    pattern.charSet(setStart, setEnd)
  ) and
  // Verify escape character at current position
  pattern.escapingChar(escapePos) and
  // Confirm 'b' character follows the escape
  pattern.getChar(escapePos + 1) = "b"
select pattern, "Backspace escape in regular expression at offset " + escapePos + "."