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

from RegExp regEx, int escapePos
where
  // Check if current position contains an escape character (backslash)
  regEx.escapingChar(escapePos) and
  // Verify the character following the backslash is 'b'
  regEx.getChar(escapePos + 1) = "b" and
  // Ensure the escape sequence is inside a character set
  exists(int setStartPos, int setEndPos |
    setStartPos < escapePos and 
    setEndPos > escapePos and
    regEx.charSet(setStartPos, setEndPos)
  )
select regEx, "Backspace escape in regular expression at offset " + escapePos + "."