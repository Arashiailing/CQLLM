/**
 * @name Regular Expression Backspace Escape
 * @description Identifies instances where '\b' is used as a backspace character in regex patterns.
 *              This usage can be misleading because '\b' commonly denotes a word boundary
 *              assertion in regular expression syntax.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/regex/backspace-escape
 */

import python
import semmle.python.regex

from RegExp regExp, int escapeLoc
where
  // Check for an escape character followed by 'b'
  regExp.escapingChar(escapeLoc) and
  regExp.getChar(escapeLoc + 1) = "b" and
  // Verify the escape sequence is within a character set
  exists(int charSetStart, int charSetEnd | 
    charSetStart < escapeLoc and 
    charSetEnd > escapeLoc and 
    regExp.charSet(charSetStart, charSetEnd)
  )
select regExp, "Backspace escape in regular expression at offset " + escapeLoc + "."