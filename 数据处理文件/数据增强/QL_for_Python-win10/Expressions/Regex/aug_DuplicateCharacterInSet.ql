/**
 * @name Duplication in regular expression character class
 * @description Duplicate characters in a class have no effect and may indicate an error in the regular expression.
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
predicate duplicate_char_in_class(RegExp regex, string repeatedChar) {
  // 查找字符类中两个不同位置但内容相同的字符
  exists(
    int firstCharStart, int firstCharEnd, 
    int secondCharStart, int secondCharEnd,
    int classStart, int classEnd |
    
    // 确保两个字符的位置索引不同
    firstCharStart != secondCharStart and
    firstCharEnd != secondCharEnd and
    
    // 验证两个字符都在字符类范围内
    classStart < firstCharStart and
    firstCharEnd < classEnd and
    classStart < secondCharStart and
    secondCharEnd < classEnd and
    
    // 获取第一个字符的文本内容
    regex.character(firstCharStart, firstCharEnd) and
    repeatedChar = regex.getText().substring(firstCharStart, firstCharEnd) and
    
    // 获取第二个字符的文本内容
    regex.character(secondCharStart, secondCharEnd) and
    repeatedChar = regex.getText().substring(secondCharStart, secondCharEnd) and
    
    // 确认这些字符位于字符集内
    regex.charSet(classStart, classEnd)
  ) and
  // 排除特殊字符 '�'，它用于表示不可编码的字符
  repeatedChar != "�" and
  // 忽略详细模式下的空白字符
  not (
    regex.getAMode() = "VERBOSE" and
    repeatedChar in [" ", "\t", "\r", "\n"]
  )
}

// 主查询：查找所有包含重复字符的正则表达式
from RegExp regex, string repeatedChar
where duplicate_char_in_class(regex, repeatedChar)
select regex,
  "This regular expression includes duplicate character '" + repeatedChar + "' in a set of characters."