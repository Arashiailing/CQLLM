/**
 * @name Ambiguous backspace escape in regex character set
 * @description Detects instances where '\b' is used within character sets in regular expressions,
 *              leading to potential confusion as it conflicts with the typical word boundary assertion.
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
  // Check for an escape character at the specified location followed by 'b'
  regexExpr.escapingChar(escapePos) and
  regexExpr.getChar(escapePos + 1) = "b" and
  // Determine if the escape sequence is within a character set context
  exists(int charSetStart, int charSetEnd |
    charSetStart < escapePos and 
    charSetEnd > escapePos and
    regexExpr.charSet(charSetStart, charSetEnd)
  )
select regexExpr, "Ambiguous backspace escape in character set at offset " + escapePos + "."