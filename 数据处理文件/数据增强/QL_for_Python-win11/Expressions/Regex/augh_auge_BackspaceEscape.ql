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

from RegExp pattern, int escapePos
where
  // 检查正则表达式中指定位置是否为转义字符（反斜杠）
  pattern.escapingChar(escapePos) and
  // 验证转义字符后紧跟的是字母'b'，形成'\b'序列
  pattern.getChar(escapePos + 1) = "b" and
  // 确保该转义序列位于字符集定义（方括号[]）内部
  exists(int setStart, int setEnd | 
    setStart < escapePos and 
    setEnd > escapePos and 
    pattern.charSet(setStart, setEnd)
  )
select pattern, "Backspace escape in regular expression at offset " + escapePos + "."