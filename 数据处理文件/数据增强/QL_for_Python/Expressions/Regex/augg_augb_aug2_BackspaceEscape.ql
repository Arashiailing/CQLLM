/**
 * @name Backspace escape in regular expression
 * @description Identifies regular expressions containing '\b' escape sequence within character sets,
 *              which represents a backspace character but is often confused with word boundary assertion.
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
  // Identify position of escape character (backslash)
  regexPattern.escapingChar(escapePos) and
  // Validate subsequent character is 'b' forming '\b' sequence
  regexPattern.getChar(escapePos + 1) = "b" and
  // Confirm sequence resides within a character set boundary
  exists(int charSetStart, int charSetEnd | 
    // Verify valid character set encompasses the escape position
    regexPattern.charSet(charSetStart, charSetEnd) and
    // Ensure character set starts before escape sequence
    charSetStart < escapePos and 
    // Ensure character set ends after escape sequence
    charSetEnd > escapePos
  )
select regexPattern, "Backspace escape in regular expression at offset " + escapePos + "."