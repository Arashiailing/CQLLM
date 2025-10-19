/**
 * @name Backspace escape in regular expression
 * @description Detects the use of '\b' to represent the backspace character in regex patterns,
 *              which can be confusing as it is commonly used as a word boundary assertion.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/regex/backspace-escape
 */

import python
import semmle.python.regex

from RegExp pattern, int offset
where
  // Check if there's an escape character at the given offset
  pattern.escapingChar(offset) and
  // Verify that the character following the escape is 'b'
  pattern.getChar(offset + 1) = "b" and
  // Ensure this escape sequence is within a character set definition
  exists(int setStart, int setEnd | 
    pattern.charSet(setStart, setEnd) and
    setStart < offset and 
    setEnd > offset
  )
select pattern, "Backspace escape in regular expression at offset " + offset + "."