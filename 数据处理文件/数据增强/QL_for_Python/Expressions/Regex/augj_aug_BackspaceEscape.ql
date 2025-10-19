/**
 * @name Backspace escape in regular expression
 * @description Detects the use of '\b' to represent the backspace character within regex character sets,
 *              which can be confusing as '\b' typically denotes a word boundary assertion.
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
  // Check for an escape character at the current position
  regexPattern.escapingChar(escapePosition) and
  // Verify that 'b' follows the escape character
  regexPattern.getChar(escapePosition + 1) = "b" and
  // Ensure the escape sequence is within a character set (square brackets)
  exists(int charSetStart, int charSetEnd |
    charSetStart < escapePosition and charSetEnd > escapePosition and
    regexPattern.charSet(charSetStart, charSetEnd)
  )
select regexPattern, "Backspace escape in regular expression at offset " + escapePosition + "."