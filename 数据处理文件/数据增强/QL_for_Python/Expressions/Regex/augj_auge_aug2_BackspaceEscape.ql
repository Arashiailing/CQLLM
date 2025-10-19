/**
 * @name Backspace escape in regular expression
 * @description Identifies instances where '\b' is used to represent a backspace character within regex character sets.
 *              This usage is potentially confusing because outside character sets, '\b' denotes a word boundary.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/regex/backspace-escape
 */

import python
import semmle.python.regex

from RegExp regexExpr, int escapePos
where
  // Locate a backslash that functions as an escape character
  regexExpr.escapingChar(escapePos) and
  // Confirm that 'b' follows the backslash, forming a backspace escape sequence
  regexExpr.getChar(escapePos + 1) = "b" and
  // Ensure the escape sequence is within a character set (square brackets)
  exists(int setStart, int setEnd | 
    regexExpr.charSet(setStart, setEnd) and
    // The escape position must be between the start and end of the character set
    setStart < escapePos and 
    setEnd > escapePos
  )
select regexExpr, "Backspace escape in regular expression at offset " + escapePos + "."