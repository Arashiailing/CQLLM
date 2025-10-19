/**
 * @name Backspace escape in regular expression
 * @description Identifies instances where '\b' is used to represent a backspace character
 *              within regular expressions, which can be confusing as '\b' typically
 *              denotes a word boundary assertion in regex patterns.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/regex/backspace-escape
 */

import python
import semmle.python.regex

from RegExp pattern, int escapePos
where
  // Check for an escape character followed by 'b'
  pattern.escapingChar(escapePos) and
  pattern.getChar(escapePos + 1) = "b" and
  // Verify the escape sequence is within a character set
  exists(int charSetStart, int charSetEnd | 
    charSetStart < escapePos and 
    charSetEnd > escapePos and 
    pattern.charSet(charSetStart, charSetEnd)
  )
select pattern, "Backspace escape in regular expression at offset " + escapePos + "."