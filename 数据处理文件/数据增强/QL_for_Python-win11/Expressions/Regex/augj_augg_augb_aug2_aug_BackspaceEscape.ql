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

from RegExp pattern, int backslashLoc
where
  // Locate backslash characters that serve as escape indicators
  pattern.escapingChar(backslashLoc) and
  // Confirm the character following the backslash is 'b'
  pattern.getChar(backslashLoc + 1) = "b" and
  // Validate the escape sequence appears within a character set definition
  exists(int setBegin, int setEnd |
    setBegin < backslashLoc and 
    setEnd > backslashLoc and
    pattern.charSet(setBegin, setEnd)
  )
select pattern, "Backspace escape in regular expression at offset " + backslashLoc + "."