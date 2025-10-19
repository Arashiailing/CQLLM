/**
 * @name Backspace escape in regular expression
 * @description Detects usage of '\b' as a backspace character within regex patterns,
 *              which may cause confusion since '\b' typically represents a word boundary
 *              assertion in regular expressions.
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
  // Identify escape character followed by 'b'
  regexPattern.escapingChar(escapePosition) and
  regexPattern.getChar(escapePosition + 1) = "b" and
  // Confirm the escape sequence is inside a character set
  exists(int charSetBegin, int charSetFinish | 
    charSetBegin < escapePosition and 
    charSetFinish > escapePosition and 
    regexPattern.charSet(charSetBegin, charSetFinish)
  )
select regexPattern, "Backspace escape in regular expression at offset " + escapePosition + "."