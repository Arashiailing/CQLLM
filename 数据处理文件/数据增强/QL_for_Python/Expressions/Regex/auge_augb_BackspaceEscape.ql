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

from RegExp pattern, int escapeLoc
where
  // Check for a backspace escape sequence at the given position
  pattern.escapingChar(escapeLoc) and pattern.getChar(escapeLoc + 1) = "b" and
  // Verify the escape sequence is contained within a character set
  exists(int charSetBegin, int charSetFinish | 
    charSetBegin < escapeLoc and 
    charSetFinish > escapeLoc and
    pattern.charSet(charSetBegin, charSetFinish)
  )
select pattern, "Backspace escape in regular expression at offset " + escapeLoc + "."