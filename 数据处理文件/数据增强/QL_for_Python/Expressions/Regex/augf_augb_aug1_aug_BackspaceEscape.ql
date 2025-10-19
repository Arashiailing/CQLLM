/**
 * @name Backspace escape in regular expression
 * @description Using '\b' to escape the backspace character in a regular expression is confusing
 *              since it could be mistaken for a word boundary assertion.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/regex/backspace-escape
 */

import python
import semmle.python.regex

from RegExp regexPattern, int escapeCharPosition
where
  // Step 1: Identify the escape character (backslash) in the regex pattern
  regexPattern.escapingChar(escapeCharPosition) and
  // Step 2: Verify that 'b' character follows the escape character, forming '\b' sequence
  regexPattern.getChar(escapeCharPosition + 1) = "b" and
  // Step 3: Confirm the escape sequence occurs within a character set (square brackets)
  exists(int charSetStart, int charSetEnd |
    charSetStart < escapeCharPosition and 
    charSetEnd > escapeCharPosition and
    regexPattern.charSet(charSetStart, charSetEnd)
  )
select regexPattern, "Backspace escape in regular expression at offset " + escapeCharPosition + "."