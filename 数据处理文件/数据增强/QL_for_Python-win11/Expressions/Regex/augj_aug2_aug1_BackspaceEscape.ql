/**
 * @name Backspace escape in regular expression
 * @description Detects the use of '\b' to represent a backspace character within regular expressions.
 *              This can be confusing because outside character sets, '\b' typically means word boundary.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/regex/backspace-escape
 */

import python
import semmle.python.regex

from RegExp regexPattern, int escapePos
where
  // Check if the character at escapePos is an escaping backslash
  regexPattern.escapingChar(escapePos) and
  // Ensure the character following the escape is 'b'
  regexPattern.getChar(escapePos + 1) = "b" and
  // Verify the escape sequence is within a character set
  exists(int charSetBegin, int charSetFinish | 
    regexPattern.charSet(charSetBegin, charSetFinish) and
    // The escape position must be inside the character set
    charSetBegin < escapePos and 
    charSetFinish > escapePos
  )
select regexPattern, "Backspace escape in regular expression at offset " + escapePos + "."