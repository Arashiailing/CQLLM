/**
 * @name Backspace escape in regular expression
 * @description Detects the usage of backspace escape sequence '\b' within character classes in regex patterns.
 *              This pattern is often mistakenly used for word boundaries, but inside character sets,
 *              it actually represents the backspace control character.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/regex/backspace-escape
 */

import python
import semmle.python.regex

from RegExp regexExpr, int escapePos
where
  // Check if the character at escapePos is a backslash used for escaping
  regexExpr.escapingChar(escapePos) and
  // Verify that the character immediately following the backslash is 'b'
  regexExpr.getChar(escapePos + 1) = "b" and
  // Determine if the escape sequence is located inside a character class
  exists(int charSetStart, int charSetEnd | 
    // Locate a character set in the regex pattern
    regexExpr.charSet(charSetStart, charSetEnd) and
    // Ensure the escape sequence falls within the character set boundaries
    charSetStart < escapePos and 
    charSetEnd > escapePos
  )
select regexExpr, "Backspace escape in regular expression at offset " + escapePos + "."