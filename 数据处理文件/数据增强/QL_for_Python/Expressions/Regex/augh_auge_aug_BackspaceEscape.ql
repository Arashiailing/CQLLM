/**
 * @name Backspace escape in regular expression
 * @description Detects confusing use of '\b' for backspace escape in regex patterns,
 *              which conflicts with word boundary assertions.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/regex/backspace-escape
 */

import python
import semmle.python.regex

from RegExp regularExpression, int escapePosition
where
  // Identify escape character at current position
  regularExpression.escapingChar(escapePosition) and
  // Confirm 'b' follows the escape sequence
  regularExpression.getChar(escapePosition + 1) = "b" and
  // Validate escape occurs within character set boundaries
  exists(int charSetStart, int charSetFinish |
    charSetStart < escapePosition and charSetFinish > escapePosition and
    regularExpression.charSet(charSetStart, charSetFinish)
  )
select regularExpression, "Backspace escape in regular expression at offset " + escapePosition + "."