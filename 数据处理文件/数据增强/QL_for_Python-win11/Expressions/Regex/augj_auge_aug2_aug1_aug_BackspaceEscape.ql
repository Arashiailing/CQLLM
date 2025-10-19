/**
 * @name Ambiguous backspace escape in regex character set
 * @description Identifies instances where '\b' appears within regex character sets,
 *              potentially causing confusion between word boundary and backspace interpretation.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/regex/backspace-escape
 */

import python
import semmle.python.regex

from RegExp regexPattern, int escapePosition
where
  // Verify character set boundaries contain the escape sequence
  exists(int setBegin, int setFinish |
    setBegin < escapePosition and 
    setFinish > escapePosition and
    regexPattern.charSet(setBegin, setFinish)
  ) and
  // Confirm escape character at current position
  regexPattern.escapingChar(escapePosition) and
  // Validate 'b' character follows the escape
  regexPattern.getChar(escapePosition + 1) = "b"
select regexPattern, "Backspace escape in regular expression at offset " + escapePosition + "."