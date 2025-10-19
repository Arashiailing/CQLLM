/**
 * @name Backspace escape in regular expression
 * @description Identifies instances where '\b' is used inside character sets in regular expressions.
 *              This sequence represents a backspace character but is often confused with word boundaries.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/regex/backspace-escape
 */

import python
import semmle.python.regex

from RegExp regexPattern, int backslashPos
where
  // Verify the character at backslashPos is an escaping backslash
  regexPattern.escapingChar(backslashPos) and
  // Ensure the character following the backslash is 'b'
  regexPattern.getChar(backslashPos + 1) = "b" and
  // Confirm the escape sequence is within a character set
  exists(int setStart, int setEnd | 
    regexPattern.charSet(setStart, setEnd) and
    // Validate the escape position falls within character set boundaries
    setStart < backslashPos and 
    setEnd > backslashPos
  )
select regexPattern, "Backspace escape in regular expression at offset " + backslashPos + "."