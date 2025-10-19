/**
 * @name Backspace escape in regular expression
 * @description Identifies instances where '\b' is used within regex character sets,
 *              which represents a backspace character but can be confused with
 *              the word boundary assertion outside character sets.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/regex/backspace-escape
 */

import python
import semmle.python.regex

from RegExp regExp, int escapePos
where
  // Check if current position contains a backslash character
  regExp.escapingChar(escapePos) and
  // Ensure the character immediately following the backslash is 'b'
  regExp.getChar(escapePos + 1) = "b" and
  // Validate that the escape sequence is within a character set (square brackets)
  exists(int charSetStart, int charSetEnd |
    regExp.charSet(charSetStart, charSetEnd) and
    charSetStart < escapePos and 
    charSetEnd > escapePos
  )
select regExp, "Backspace escape in regular expression at offset " + escapePos + "."