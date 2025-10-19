/**
 * @name Backspace escape in regular expression
 * @description Detects when '\b' is used to represent a backspace character within regex character sets,
 *              which can be confused with the word boundary assertion '\b'.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/regex/backspace-escape
 */

import python
import semmle.python.regex

from RegExp regularExpr, int escapeLocation
where
  // Identify escape backslash character at the given position
  regularExpr.escapingChar(escapeLocation) and
  // Verify the character following the escape is 'b', forming '\b'
  regularExpr.getChar(escapeLocation + 1) = "b" and
  // Confirm the escape sequence is inside a character set [...]
  exists(int charSetStart, int charSetEnd | 
    charSetStart < escapeLocation and 
    charSetEnd > escapeLocation and 
    regularExpr.charSet(charSetStart, charSetEnd)
  )
select regularExpr, "Backspace escape in regular expression at offset " + escapeLocation + "."