/**
 * @name Ambiguous backspace escape in regex character set
 * @description The use of '\b' inside character sets to represent backspace is ambiguous
 *              because it conflicts with the standard word boundary assertion interpretation.
 *              This can lead to confusion and potential bugs in regular expression patterns.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/regex/backspace-escape
 */

import python
import semmle.python.regex

from RegExp regexPattern, int escapeCharPosition
where
  // Identify escape character at the current position in the regex pattern
  regexPattern.escapingChar(escapeCharPosition) and
  // Confirm that 'b' immediately follows the escape character, forming '\b'
  regexPattern.getChar(escapeCharPosition + 1) = "b" and
  // Ensure this '\b' sequence is contained within a character set definition
  exists(int charSetStart, int charSetEnd |
    // The position must be within the bounds of a character set
    charSetStart < escapeCharPosition and 
    charSetEnd > escapeCharPosition and
    // Verify these positions indeed define a character set
    regexPattern.charSet(charSetStart, charSetEnd)
  )
select regexPattern, "Ambiguous backspace escape in character set at offset " + escapeCharPosition + "."