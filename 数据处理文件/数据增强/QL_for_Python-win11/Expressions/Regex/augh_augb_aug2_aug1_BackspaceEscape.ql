/**
 * @name Backspace escape in regular expression
 * @description Detects the use of '\b' to represent a backspace character within regular expressions,
 *              which can lead to confusion as it is commonly interpreted as a word boundary.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/regex/backspace-escape
 */

import python
import semmle.python.regex

from RegExp regexPattern, int backslashPos
where
  // Locate a backslash character used for escaping at the specified position
  regexPattern.escapingChar(backslashPos) and
  // Verify that the character immediately following the backslash is 'b'
  regexPattern.getChar(backslashPos + 1) = "b" and
  // Check if this escape sequence is contained within a character set
  exists(int charSetStart, int charSetEnd | 
    // Identify a character set that encompasses the escape sequence
    regexPattern.charSet(charSetStart, charSetEnd) and
    // Ensure the backslash position falls within the character set boundaries
    charSetStart < backslashPos and 
    charSetEnd > backslashPos
  )
select regexPattern, "Backspace escape in regular expression at offset " + backslashPos + "."