/**
 * @name Backspace escape in regular expression
 * @description Identifies confusing usage of '\b' as backspace character within regex character sets,
 *              since it's commonly interpreted as word boundary assertion outside character sets.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/regex/backspace-escape
 */

import python
import semmle.python.regex

from RegExp re, int escPos
where
  // Verify escape character exists at current position
  re.escapingChar(escPos) and
  // Confirm next character is 'b' forming '\b' sequence
  re.getChar(escPos + 1) = "b" and
  // Ensure escape sequence occurs within character set boundaries
  exists(int setStart, int setEnd |
    re.charSet(setStart, setEnd) and
    setStart < escPos and
    escPos < setEnd
  )
select re, "Backspace escape in regular expression at offset " + escPos + "."