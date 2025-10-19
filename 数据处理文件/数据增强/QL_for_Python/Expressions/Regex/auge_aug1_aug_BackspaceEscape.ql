/**
 * @name Backspace escape in regular expression
 * @description Detects usage of '\b' to represent backspace character within regex character sets,
 *              which can be confused with word boundary assertions.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/regex/backspace-escape
 */

import python
import semmle.python.regex

from RegExp regexPattern, int escapeCharPos
where
  // Identify escape character position in the regex pattern
  regexPattern.escapingChar(escapeCharPos) and
  // Check if 'b' follows the escape character, forming '\b' sequence
  regexPattern.getChar(escapeCharPos + 1) = "b" and
  // Verify the escape sequence is inside a character set definition
  exists(int charSetBeginPos, int charSetEndPos |
    // Character set boundaries must enclose the escape position
    charSetBeginPos < escapeCharPos and 
    charSetEndPos > escapeCharPos and
    // Confirm these positions define a valid character set
    regexPattern.charSet(charSetBeginPos, charSetEndPos)
  )
select regexPattern, "Backspace escape in regular expression at offset " + escapeCharPos + "."