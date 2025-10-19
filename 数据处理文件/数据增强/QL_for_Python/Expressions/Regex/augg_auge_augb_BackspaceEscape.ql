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

from RegExp pattern, int backspacePos
where
  // Identify backspace escape sequence at position backspacePos
  pattern.escapingChar(backspacePos) and 
  pattern.getChar(backspacePos + 1) = "b" and
  // Verify the escape sequence is contained within a character set
  exists(int charSetStart, int charSetEnd | 
    charSetStart < backspacePos and 
    charSetEnd > backspacePos and
    pattern.charSet(charSetStart, charSetEnd)
  )
select pattern, "Backspace escape in regular expression at offset " + backspacePos + "."