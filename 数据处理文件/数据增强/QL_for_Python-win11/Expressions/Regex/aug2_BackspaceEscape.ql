/**
 * @name Backspace escape in regular expression
 * @description Detects the use of '\b' to escape the backspace character in regular expressions,
 *              which is confusing as it could be mistaken for a word boundary assertion.
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
  // Verify there's an escape character (backslash) at the specified position
  regexExpr.escapingChar(escapePos) and
  // Check if the character immediately following the escape is 'b'
  regexExpr.getChar(escapePos + 1) = "b" and
  // Confirm the escape sequence occurs within a character set definition
  exists(int charSetStart, int charSetEnd | 
    charSetStart < escapePos and 
    charSetEnd > escapePos | 
    regexExpr.charSet(charSetStart, charSetEnd)
  )
select regexExpr, "Backspace escape in regular expression at offset " + escapePos + "."