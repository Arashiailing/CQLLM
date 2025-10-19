/**
 * @name Regex Backspace Escape Confusion
 * @description Identifies potentially confusing usage of '\b' escape sequence within regex character sets,
 *              where it might be interpreted as word boundary instead of backspace character.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/regex/backspace-escape
 */

import python
import semmle.python.regex

from RegExp regexPattern, int backslashPosition
where
  // First, verify the position contains an escape character (backslash)
  regexPattern.escapingChar(backslashPosition) and
  // Then, confirm the character following backslash is 'b'
  regexPattern.getChar(backslashPosition + 1) = "b" and
  // Finally, ensure the escape sequence is inside a character set
  exists(int charSetStart, int charSetEnd |
    // Character set boundaries must contain the backslash position
    charSetStart < backslashPosition and 
    charSetEnd > backslashPosition and
    // Verify the character set exists in the regex pattern
    regexPattern.charSet(charSetStart, charSetEnd)
  )
select regexPattern, "Backspace escape in regular expression at offset " + backslashPosition + "."