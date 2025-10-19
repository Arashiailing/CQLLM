/**
 * @name Regular expression backspace escape confusion
 * @description Detects occurrences of '\b' inside regex character classes, where it represents
 *              a backspace character but might be confused with the word boundary assertion '\b'.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/regex/backspace-escape
 */

import python
import semmle.python.regex

from RegExp regexpPattern, int escapeLocation
where
  // Check if there's an escape character at the given location
  regexpPattern.escapingChar(escapeLocation) and
  // Verify the escaped character is 'b'
  regexpPattern.getChar(escapeLocation + 1) = "b" and
  // Ensure the escape sequence is within a character set
  exists(int charSetStart, int charSetEnd | 
    charSetStart < escapeLocation and 
    charSetEnd > escapeLocation and 
    regexpPattern.charSet(charSetStart, charSetEnd)
  )
select regexpPattern, "Backspace escape in regular expression at offset " + escapeLocation + "."