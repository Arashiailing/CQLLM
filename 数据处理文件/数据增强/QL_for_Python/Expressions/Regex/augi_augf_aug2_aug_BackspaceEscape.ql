/**
 * @name Backspace escape in regular expression
 * @description Detects ambiguous '\b' usage within regex character sets,
 *              where it might represent backspace but is interpreted as word boundary.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/regex/backspace-escape
 */

import python
import semmle.python.regex

from RegExp regexPattern, int escapePos
where
  // Identify backslash escape character at specific position
  regexPattern.escapingChar(escapePos) and
  // Verify character class contains this escape sequence
  exists(int charSetStart, int charSetEnd |
    // Character class must fully contain the escape sequence
    charSetStart < escapePos and 
    charSetEnd > escapePos and
    // Confirm valid character class boundaries
    regexPattern.charSet(charSetStart, charSetEnd)
  ) and
  // Ensure 'b' follows immediately after backslash
  regexPattern.getChar(escapePos + 1) = "b"
select regexPattern, "Backspace escape in regular expression at offset " + escapePos + "."