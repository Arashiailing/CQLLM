/**
 * @name Backspace escape in regular expression
 * @description Detects when '\b' appears inside regex character sets, which represents
 *              a backspace character but is often confused with word boundary assertion '\b'.
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
  // Verify escape sequence is within a character set [...]
  exists(int charSetStart, int charSetEnd | 
    charSetStart < escapePosition and 
    charSetEnd > escapePosition and 
    regexPattern.charSet(charSetStart, charSetEnd)
  ) and
  // Confirm backslash escape character at specified position
  regexPattern.escapingChar(escapePosition) and
  // Validate following character is 'b' to form '\b' sequence
  regexPattern.getChar(escapePosition + 1) = "b"
select regexPattern, "Backspace escape in regular expression at offset " + escapePosition + "."