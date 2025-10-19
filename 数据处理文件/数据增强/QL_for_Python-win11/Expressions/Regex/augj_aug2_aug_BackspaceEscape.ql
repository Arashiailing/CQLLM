/**
 * @name Backspace escape in regular expression
 * @description Identifies instances where '\b' is used for backspace within regex character sets,
 *              potentially causing confusion with word boundary assertions.
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
  // Find the position of the backslash character used for escaping
  regexPattern.escapingChar(backslashPosition) and
  // Check that 'b' follows the backslash, forming the \b sequence
  regexPattern.getChar(backslashPosition + 1) = "b" and
  // Ensure this escape sequence is contained within a character set definition
  exists(int charSetStart, int charSetEnd |
    // Verify the escape sequence is between the opening and closing brackets of a character set
    charSetStart < backslashPosition and 
    charSetEnd > backslashPosition and
    regexPattern.charSet(charSetStart, charSetEnd)
  )
select regexPattern, "Backspace escape in regular expression at offset " + backslashPosition + "."