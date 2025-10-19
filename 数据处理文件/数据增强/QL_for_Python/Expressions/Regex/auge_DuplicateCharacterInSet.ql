/**
 * @name Duplication in regular expression character class
 * @description Identifies duplicate characters within regex character classes which have no effect and may indicate errors.
 * @kind problem
 * @tags reliability
 *       readability
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/regex/duplicate-in-character-class
 */

import python
import semmle.python.regex

// 谓词：检测正则表达式字符类中是否存在重复字符
predicate hasDuplicateCharInClass(RegExp regex, string duplicateChar) {
  // 查找两个不同位置对在字符类范围内表示相同字符
  exists(
    int firstCharStart, int firstCharEnd, 
    int secondCharStart, int secondCharEnd,
    int charClassStart, int charClassEnd
  |
    // 确保两个字符位置不同
    not (firstCharStart = secondCharStart and firstCharEnd = secondCharEnd) and
    // 第一个字符在字符类范围内
    charClassStart < firstCharStart and firstCharEnd < charClassEnd and
    // 第二个字符在字符类范围内
    charClassStart < secondCharStart and secondCharEnd < charClassEnd and
    // 验证两个位置都是有效字符
    regex.character(firstCharStart, firstCharEnd) and
    regex.character(secondCharStart, secondCharEnd) and
    // 获取相同字符值
    duplicateChar = regex.getText().substring(firstCharStart, firstCharEnd) and
    duplicateChar = regex.getText().substring(secondCharStart, secondCharEnd) and
    // 确认位于字符集内
    regex.charSet(charClassStart, charClassEnd)
  ) and
  // 排除特殊字符 � (用于不可编码字符)
  duplicateChar != "�" and
  // 忽略详细模式下的空白字符
  not (
    regex.getAMode() = "VERBOSE" and 
    duplicateChar in [" ", "\t", "\r", "\n"]
  )
}

// 主查询：查找包含重复字符的正则表达式
from RegExp regex, string duplicateChar
where hasDuplicateCharInClass(regex, duplicateChar)
select regex, 
  "Regular expression contains duplicate character '" + duplicateChar + "' in character class."