/**
 * @name Backspace escape in regular expression
 * @description The use of '\b' to represent a backspace character within regular expressions
 *              can lead to confusion, as it is commonly interpreted as a word boundary.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/regex/backspace-escape
 */

import python
import semmle.python.regex

from RegExp rePattern, int escapePosition
where
  // Confirm that the character at escapePosition is an escaping backslash
  rePattern.escapingChar(escapePosition) and
  // Verify that the character following the escape is 'b'
  rePattern.getChar(escapePosition + 1) = "b" and
  // Check that the escape sequence is inside a character set
  exists(int charSetStart, int charSetEnd | 
    rePattern.charSet(charSetStart, charSetEnd) and
    // The escape position must be within the character set boundaries
    charSetStart < escapePosition and 
    charSetEnd > escapePosition
  )
select rePattern, "Backspace escape in regular expression at offset " + escapePosition + "."