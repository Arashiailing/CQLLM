/**
 * @name Backspace escape in regular expression
 * @description Using '\b' to escape the backspace character in a regular expression is confusing
 *              since it could be mistaken for a word boundary assertion.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/regex/backspace-escape
 */

import python
import semmle.python.regex

from RegExp regex, int position
where
  // Verify escape character exists at specified position
  regex.escapingChar(position) and
  // Confirm subsequent character is 'b' after escape
  regex.getChar(position + 1) = "b" and
  // Ensure position is enclosed within a character set boundary
  exists(int startIdx, int endIdx | 
    startIdx < position and endIdx > position and 
    regex.charSet(startIdx, endIdx)
  )
select regex, "Backspace escape in regular expression at offset " + position + "."