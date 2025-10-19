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

// 定义一个谓词函数，用于检测正则表达式字符类中是否存在重复字符
predicate duplicate_char_in_class(RegExp r, string char) {
  // 检查是否存在两个不同的索引对 (i, j) 和 (x, y)，它们在字符类范围内且表示相同的字符
  exists(int i, int j, int x, int y, int start, int end |
    i != x and // 确保第一个字符的起始索引不同
    j != y and // 确保第一个字符的结束索引不同
    start < i and // 确保第一个字符的起始索引在字符类范围内
    j < end and // 确保第一个字符的结束索引在字符类范围内
    start < x and // 确保第二个字符的起始索引在字符类范围内
    y < end and // 确保第二个字符的结束索引在字符类范围内
    r.character(i, j) and // 确保第一个字符是字符类的一部分
    char = r.getText().substring(i, j) and // 获取第一个字符的文本内容
    r.character(x, y) and // 确保第二个字符是字符类的一部分
    char = r.getText().substring(x, y) and // 获取第二个字符的文本内容
    r.charSet(start, end) // 确保这些字符位于字符集内
  ) and
  /* Exclude � as we use it for any unencodable character */
  char != "�" and // 排除特殊字符 '�'，因为它用于表示任何不可编码的字符
  // 忽略详细模式下的空白字符
  not (
    r.getAMode() = "VERBOSE" and // 如果正则表达式处于详细模式
    char in [" ", "\t", "\r", "\n"] // 并且字符是空白字符之一
  )
}

// 查询语句：查找所有包含重复字符的正则表达式字符类
from RegExp r, string char
where duplicate_char_in_class(r, char) // 使用谓词函数过滤出存在重复字符的正则表达式
select r, // 选择正则表达式对象
  "This regular expression includes duplicate character '" + char + "' in a set of characters." // 输出警告信息，指出重复的字符
