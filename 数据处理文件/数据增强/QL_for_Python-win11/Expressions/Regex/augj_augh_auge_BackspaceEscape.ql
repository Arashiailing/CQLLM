/**
 * @name Ambiguous backspace escape in regex patterns
 * @description The '\b' sequence in regex patterns can represent either a backspace character
 *              or a word boundary assertion, causing potential confusion and maintenance issues.
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
  // Identify positions where an escape character (backslash) appears
  regexPattern.escapingChar(escapePosition) and
  // Verify that the escape character is followed by 'b', forming the '\b' sequence
  regexPattern.getChar(escapePosition + 1) = "b" and
  // Ensure the escape sequence is located within a character set definition (square brackets [])
  exists(int charSetStart, int charSetEnd | 
    charSetStart < escapePosition and 
    charSetEnd > escapePosition and 
    regexPattern.charSet(charSetStart, charSetEnd)
  )
select regexPattern, "Backspace escape in regular expression at offset " + escapePosition + "."