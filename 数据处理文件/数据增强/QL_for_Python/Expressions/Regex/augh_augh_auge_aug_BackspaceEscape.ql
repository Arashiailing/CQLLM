/**
 * @name Backspace escape in regular expression
 * @description Detects confusing use of '\b' for backspace escape in regex patterns,
 *              which conflicts with word boundary assertions.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/regex/backspace-escape
 */

import python
import semmle.python.regex

from RegExp regexPattern, int escapeCharPos
where
  // Locate escape character position in the regex pattern
  regexPattern.escapingChar(escapeCharPos) and
  // Verify 'b' character follows the escape sequence
  regexPattern.getChar(escapeCharPos + 1) = "b" and
  // Check if escape occurs within character set boundaries
  exists(int charSetStart, int charSetEnd |
    // Escape position must be within character set range
    charSetStart < escapeCharPos and charSetEnd > escapeCharPos and
    // Validate character set definition in regex
    regexPattern.charSet(charSetStart, charSetEnd)
  )
select regexPattern, "Backspace escape in regular expression at offset " + escapeCharPos + "."