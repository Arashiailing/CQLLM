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

from RegExp regexPattern, int escapePosition
where
  // 验证指定位置存在转义字符
  regexPattern.escapingChar(escapePosition) and
  // 验证转义字符后紧跟字符'b'
  regexPattern.getChar(escapePosition + 1) = "b" and
  // 确认转义序列位于字符集边界内
  exists(int charSetStart, int charSetEnd | 
    charSetStart < escapePosition and 
    charSetEnd > escapePosition | 
    regexPattern.charSet(charSetStart, charSetEnd)
  )
select regexPattern, "Backspace escape in regular expression at offset " + escapePosition + "."