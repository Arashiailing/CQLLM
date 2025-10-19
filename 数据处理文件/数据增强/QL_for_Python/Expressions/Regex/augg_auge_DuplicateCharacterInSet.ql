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

// 谓词：判断正则表达式字符类中是否存在重复字符
predicate containsDuplicateInCharClass(RegExp regex, string repeatedChar) {
  // 检查字符类中是否有两个不同位置的相同字符
  exists(
    int initialCharStart, int initialCharEnd, 
    int subsequentCharStart, int subsequentCharEnd,
    int charClassStart, int charClassEnd
  |
    // 确保两个字符位置不同
    not (initialCharStart = subsequentCharStart and initialCharEnd = subsequentCharEnd) and
    
    // 验证两个位置都是有效字符
    regex.character(initialCharStart, initialCharEnd) and
    regex.character(subsequentCharStart, subsequentCharEnd) and
    
    // 确认位于字符集内
    regex.charSet(charClassStart, charClassEnd) and
    
    // 定义字符在字符类中的位置关系
    charClassStart < initialCharStart and initialCharEnd < charClassEnd and
    charClassStart < subsequentCharStart and subsequentCharEnd < charClassEnd and
    
    // 获取相同字符值
    repeatedChar = regex.getText().substring(initialCharStart, initialCharEnd) and
    repeatedChar = regex.getText().substring(subsequentCharStart, subsequentCharEnd)
  ) and
  // 排除特殊字符 � (用于不可编码字符)
  repeatedChar != "�" and
  // 忽略详细模式下的空白字符
  not (
    regex.getAMode() = "VERBOSE" and 
    repeatedChar in [" ", "\t", "\r", "\n"]
  )
}

// 主查询：识别包含重复字符的正则表达式
from RegExp regex, string repeatedChar
where containsDuplicateInCharClass(regex, repeatedChar)
select regex, 
  "Regular expression contains duplicate character '" + repeatedChar + "' in character class."