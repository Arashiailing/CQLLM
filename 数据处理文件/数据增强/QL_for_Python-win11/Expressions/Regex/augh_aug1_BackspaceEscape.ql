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

from RegExp regex, int backslashPos
where
  // Check if the character at backslashPos is an escape backslash
  regex.escapingChar(backslashPos) and
  // Verify the character immediately after the backslash is 'b'
  regex.getChar(backslashPos + 1) = "b" and
  // Ensure the '\b' sequence is contained within a character set
  exists(int charSetStart, int charSetEnd | 
    charSetStart < backslashPos and 
    charSetEnd > backslashPos and 
    regex.charSet(charSetStart, charSetEnd)
  )
select regex, "Backspace escape in regular expression at offset " + backslashPos + "."