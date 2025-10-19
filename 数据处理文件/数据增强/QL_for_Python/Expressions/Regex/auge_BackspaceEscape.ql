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
  // 验证指定偏移位置存在转义字符
  regex.escapingChar(position) and
  // 确认转义字符后紧跟着字符 'b'
  regex.getChar(position + 1) = "b" and
  // 保证该转义序列位于字符集定义范围内
  exists(int charSetStart, int charSetEnd | 
    charSetStart < position and 
    charSetEnd > position and 
    regex.charSet(charSetStart, charSetEnd)
  )
select regex, "Backspace escape in regular expression at offset " + position + "."