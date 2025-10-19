/**
 * @name Backspace escape in regular expression
 * @description Detects the use of '\b' to represent a backspace character within regular expressions,
 *              which can be confusing as it's commonly used as a word boundary assertion.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/regex/backspace-escape
 */

import python
import semmle.python.regex

from RegExp regex, int escapePosition
where
  // Condition 1: Verify the presence of an escape character at the specified position
  regex.escapingChar(escapePosition) and
  // Condition 2: Check if the character following the escape is 'b', forming '\b'
  regex.getChar(escapePosition + 1) = "b" and
  // Condition 3: Ensure the escape sequence is within a character set context
  exists(int charSetStart, int charSetEnd | 
    charSetStart < escapePosition and 
    charSetEnd > escapePosition and
    regex.charSet(charSetStart, charSetEnd)
  )
select regex, "Backspace escape in regular expression at offset " + escapePosition + "."