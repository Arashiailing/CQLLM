/**
 * @name Backspace escape in regular expression
 * @description Detects confusing use of '\b' within regex character sets,
 *              where it represents backspace but resembles word boundary.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/regex/backspace-escape
 */

import python
import semmle.python.regex

from RegExp regex, int escapePosition
where
  // Identify escape backslash at current position
  regex.escapingChar(escapePosition) and
  // Verify following character is 'b' forming \b sequence
  regex.getChar(escapePosition + 1) = "b" and
  // Confirm escape sequence resides within character set brackets
  exists(int charSetStart, int charSetEnd | 
    charSetStart < escapePosition and 
    charSetEnd > escapePosition and 
    regex.charSet(charSetStart, charSetEnd)
  )
select regex, "Backspace escape in regular expression at offset " + escapePosition + "."