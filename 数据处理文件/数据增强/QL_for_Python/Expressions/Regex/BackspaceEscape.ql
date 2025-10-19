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

from RegExp r, int offset
where
  // 检查在给定偏移量处是否有转义字符
  r.escapingChar(offset) and
  // 检查转义字符后是否为字符 'b'
  r.getChar(offset + 1) = "b" and
  // 确保在偏移量之前和之后存在字符集
  exists(int start, int end | start < offset and end > offset | r.charSet(start, end))
select r, "Backspace escape in regular expression at offset " + offset + "."
