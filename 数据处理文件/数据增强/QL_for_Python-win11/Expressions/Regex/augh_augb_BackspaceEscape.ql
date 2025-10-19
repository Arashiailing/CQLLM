/**
 * @name Backspace escape in regular expression
 * @description Detects the use of '\b' to represent a backspace character within regular expressions,
 *              which can be confusing as it's commonly used as a word boundary assertion.
 *              Specifically, this query flags '\b' when it appears inside a character set (square brackets),
 *              where it represents a backspace character rather than a word boundary.
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
  // Condition 1: Verify the presence of an escape character (backslash) at the specified position
  regex.escapingChar(backslashPos) and
  // Condition 2: Check if the character following the backslash is 'b', forming the '\b' sequence
  regex.getChar(backslashPos + 1) = "b" and
  // Condition 3: Ensure the '\b' sequence is within a character set context (inside square brackets []),
  // where '\b' represents a backspace character, not a word boundary
  exists(int charSetBeginPos, int charSetEndPos | 
    charSetBeginPos < backslashPos and 
    charSetEndPos > backslashPos and
    regex.charSet(charSetBeginPos, charSetEndPos)
  )
select regex, "Backspace escape in regular expression at offset " + backslashPos + "."