/**
 * @name Backspace escape in regular expression
 * @description The use of '\b' to represent the backspace character in a regular expression is
 *              confusing, as it is commonly used as a word boundary assertion.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/regex/backspace-escape
 */

import python
import semmle.python.regex

from RegExp regex, int backslashOffset
where
  // Identify backslash position used for escaping
  regex.escapingChar(backslashOffset) and
  // Verify subsequent character is 'b' forming backspace sequence
  regex.getChar(backslashOffset + 1) = "b" and
  // Confirm sequence is within character set boundaries
  exists(int charSetBegin, int charSetEnd | 
    charSetBegin < backslashOffset and 
    charSetEnd > backslashOffset and 
    regex.charSet(charSetBegin, charSetEnd)
  )
select regex, "Backspace escape in regular expression at offset " + backslashOffset + "."