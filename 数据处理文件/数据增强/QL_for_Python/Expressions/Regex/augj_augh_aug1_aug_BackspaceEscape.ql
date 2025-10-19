/**
 * @name Ambiguous backspace escape in regex character sets
 * @description The '\b' sequence inside character sets is interpreted as backspace,
 *              but outside character sets it means word boundary. This inconsistency
 *              can lead to confusion and potential errors in regular expressions.
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
  // Locate backslash character at current position
  regexPattern.escapingChar(escapePos) and
  // Ensure 'b' character immediately follows the backslash
  regexPattern.getChar(escapePos + 1) = "b" and
  // Verify the escape sequence is contained within a character set
  exists(int setStartPos, int setEndPos |
    setStartPos < escapePos and 
    setEndPos > escapePos and
    regexPattern.charSet(setStartPos, setEndPos)
  )
select regexPattern, "Ambiguous backspace escape at offset " + escapePos + " (conflicts with word boundary assertion)."