/**
 * @name Backspace escape in regular expression
 * @description The use of '\b' to represent a backspace character within regular expressions
 *              can lead to confusion, as it is commonly interpreted as a word boundary.
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
  // Identify a backslash character used for escaping at the given position
  regexPattern.escapingChar(escapePos) and
  // Check if the character immediately following the backslash is 'b'
  regexPattern.getChar(escapePos + 1) = "b" and
  // Determine if this escape sequence is located inside a character set
  exists(int setStart, int setEnd | 
    // Find a character set that contains the escape sequence
    regexPattern.charSet(setStart, setEnd) and
    // Ensure the escape position is within the boundaries of the character set
    setStart < escapePos and 
    setEnd > escapePos
  )
select regexPattern, "Backspace escape in regular expression at offset " + escapePos + "."