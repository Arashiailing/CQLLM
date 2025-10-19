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

from RegExp patternExpr, int backslashPos
where
  // Locate backslash character used for escaping
  patternExpr.escapingChar(backslashPos) and
  // Verify the character following backslash is 'b'
  patternExpr.getChar(backslashPos + 1) = "b" and
  // Ensure the escape sequence is inside a character set definition
  exists(int setStartPos, int setEndPos | 
    // Character set must start before the backslash
    setStartPos < backslashPos and 
    // Character set must end after the backslash
    setEndPos > backslashPos and 
    // Confirm the positions define a valid character set
    patternExpr.charSet(setStartPos, setEndPos)
  )
select patternExpr, "Backspace escape in regular expression at offset " + backslashPos + "."