/**
 * @name Ambiguous backspace escape in regex patterns
 * @description Detects usage of '\b' to represent backspace in regex character sets,
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

from RegExp pattern, int offset
where
  // First verify the pattern contains an escape character followed by 'b'
  pattern.escapingChar(offset) and
  pattern.getChar(offset + 1) = "b" and
  // Then ensure this escape sequence occurs within a character set definition
  exists(int charSetBegin, int charSetFinish |
    charSetBegin < offset and charSetFinish > offset and
    pattern.charSet(charSetBegin, charSetFinish)
  )
select pattern, "Backspace escape in regular expression at offset " + offset + "."