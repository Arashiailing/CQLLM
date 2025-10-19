/**
 * @name Backspace escape in regular expression
 * @description Detects confusing use of '\b' for backspace in regex patterns,
 *              which could be misinterpreted as word boundary assertion.
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
  // Verify character at escapePos is a backslash (escape character)
  regex.escapingChar(escapePos) and
  // Check if the character immediately following is 'b'
  regex.getChar(escapePos + 1) = "b" and
  // Confirm this escape sequence occurs within a character class
  exists(int charSetStart, int charSetEnd | 
         charSetStart < escapePos and 
         charSetEnd > escapePos | 
         regex.charSet(charSetStart, charSetEnd))
select regex, "Backspace escape in regular expression at offset " + escapePos + "."