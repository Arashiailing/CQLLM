/**
 * @name Backspace escape in regular expression
 * @description Identifies regular expression patterns where '\b' is used as a backspace character
 *              within character sets. This usage is potentially confusing since '\b' typically
 *              represents a word boundary assertion in regex patterns.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/regex/backspace-escape
 */

import python
import semmle.python.regex

from RegExp regexPattern, int backslashBPosition
where
  // Check for a backslash character followed by 'b' at the specified position
  regexPattern.escapingChar(backslashBPosition) and 
  regexPattern.getChar(backslashBPosition + 1) = "b"
  and
  // Ensure the backspace escape sequence is inside a character set
  exists(int charSetBegin, int charSetFinish | 
    regexPattern.charSet(charSetBegin, charSetFinish) and
    charSetBegin < backslashBPosition and 
    charSetFinish > backslashBPosition
  )
select regexPattern, "Backspace escape in regular expression at offset " + backslashBPosition + "."