/**
 * @name Regex Backspace Escape Confusion
 * @description Detects ambiguous use of '\b' in regex character sets where it could be 
 *              misinterpreted as word boundary instead of backspace character.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/regex/backspace-escape
 */

import python
import semmle.python.regex

from RegExp regexPattern, int escapePosition
where
  // Verify the escape sequence is within a character set
  exists(int charSetBegin, int charSetEnd |
    charSetBegin < escapePosition and 
    charSetEnd > escapePosition and
    regexPattern.charSet(charSetBegin, charSetEnd)
  ) and
  // Confirm current position contains a backslash escape character
  regexPattern.escapingChar(escapePosition) and
  // Ensure the character following the backslash is 'b'
  regexPattern.getChar(escapePosition + 1) = "b"
select regexPattern, "Backspace escape in regular expression at offset " + escapePosition + "."