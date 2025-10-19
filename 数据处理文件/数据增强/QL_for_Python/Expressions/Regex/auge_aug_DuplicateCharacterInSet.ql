/**
 * @name Duplication in regular expression character class
 * @description Identifies regular expressions containing duplicate characters within character classes,
 *              which are redundant and may indicate a logical error in the pattern.
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

// 谓词：检测正则表达式字符类中的重复字符
predicate duplicate_char_in_class(RegExp regex, string duplicateChar) {
  exists(
    int firstCharPosStart, int firstCharPosEnd, 
    int secondCharPosStart, int secondCharPosEnd,
    int charClassStart, int charClassEnd |
    
    // 确保两个字符的位置索引不同
    firstCharPosStart != secondCharPosStart and
    firstCharPosEnd != secondCharPosEnd and
    
    // 验证两个字符都在字符类范围内
    charClassStart < firstCharPosStart and
    firstCharPosEnd < charClassEnd and
    charClassStart < secondCharPosStart and
    secondCharPosEnd < charClassEnd and
    
    // 确认这些字符位于字符集内
    regex.charSet(charClassStart, charClassEnd) and
    
    // 获取第一个字符的文本内容
    regex.character(firstCharPosStart, firstCharPosEnd) and
    duplicateChar = regex.getText().substring(firstCharPosStart, firstCharPosEnd) and
    
    // 获取第二个字符的文本内容
    regex.character(secondCharPosStart, secondCharPosEnd) and
    duplicateChar = regex.getText().substring(secondCharPosStart, secondCharPosEnd)
  ) and
  // 排除特殊字符 '�'，它用于表示不可编码的字符
  duplicateChar != "�" and
  // 忽略详细模式下的空白字符
  not (
    regex.getAMode() = "VERBOSE" and
    duplicateChar in [" ", "\t", "\r", "\n"]
  )
}

// 主查询：查找所有包含重复字符的正则表达式
from RegExp regex, string duplicateChar
where duplicate_char_in_class(regex, duplicateChar)
select regex,
  "This regular expression includes duplicate character '" + duplicateChar + "' in a set of characters."