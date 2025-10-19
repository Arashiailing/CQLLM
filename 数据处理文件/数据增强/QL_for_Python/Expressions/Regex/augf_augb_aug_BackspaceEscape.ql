/**
 * @name Ambiguous backspace escape in regex character set
 * @description Identifies usage of '\b' inside character sets which creates confusion
 *              due to conflict with the common word boundary assertion interpretation.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/regex/backspace-escape
 */

import python
import semmle.python.regex

from RegExp regexPattern, int escapeLocation
where
  // Determine if the escape sequence is within a character set context
  exists(int charSetBegin, int charSetFinish |
    charSetBegin < escapeLocation and 
    charSetFinish > escapeLocation and
    regexPattern.charSet(charSetBegin, charSetFinish)
  ) and
  // Check for an escape character at the specified location
  regexPattern.escapingChar(escapeLocation) and
  // Verify that 'b' character follows the escape character
  regexPattern.getChar(escapeLocation + 1) = "b"
select regexPattern, "Ambiguous backspace escape in character set at offset " + escapeLocation + "."