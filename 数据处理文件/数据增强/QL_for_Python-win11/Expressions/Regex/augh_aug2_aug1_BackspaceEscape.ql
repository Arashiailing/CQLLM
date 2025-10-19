/**
 * @name Backspace escape in regular expression
 * @description Detects potentially confusing use of '\b' inside regex character sets.
 *              While '\b' typically means word boundary, it represents backspace
 *              when used within character sets, which may lead to unintended behavior.
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
  // Identify backslash characters acting as escape sequences
  regexPattern.escapingChar(backslashPos) and
  // Verify the escaped character is 'b' (backspace)
  regexPattern.getChar(backslashPos + 1) = "b" and
  // Ensure the escape sequence occurs within a character set
  exists(int charSetBegin, int charSetEnd | 
    regexPattern.charSet(charSetBegin, charSetEnd) and
    // Position validation: backslash must be inside character set boundaries
    backslashPos > charSetBegin and 
    backslashPos < charSetEnd
  )
select regexPattern, "Backspace escape in regular expression at offset " + backslashPos + "."