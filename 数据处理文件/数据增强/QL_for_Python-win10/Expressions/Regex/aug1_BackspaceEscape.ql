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

from RegExp regex, int escapePos
where
  // Verify the character at escapePos is an escape backslash
  regex.escapingChar(escapePos) and
  // Check if the character immediately after escape is 'b'
  regex.getChar(escapePos + 1) = "b" and
  // Ensure the escape sequence is contained within a character set
  exists(int setStart, int setEnd | 
    setStart < escapePos and 
    setEnd > escapePos and 
    regex.charSet(setStart, setEnd)
  )
select regex, "Backspace escape in regular expression at offset " + escapePos + "."