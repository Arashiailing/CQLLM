/**
 * @name Unmatchable dollar in regular expression
 * @description Regular expressions containing a dollar '$' in the middle cannot be matched, whatever the input.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/regex/unmatchable-dollar
 */

import python
import semmle.python.regex

// 检查正则表达式中是否存在无效的美元符号位置
predicate has_unmatchable_dollar(RegExp regex, int position) {
  // 验证正则表达式模式不包含多行或详细模式
  not (regex.getAMode() = "MULTILINE" or regex.getAMode() = "VERBOSE") and
  // 确认指定位置存在美元符号
  regex.specialCharacter(position, position + 1, "$") and
  // 验证该位置不是正则表达式的末尾
  not regex.lastItem(position, position + 1)
}

// 查询存在无效美元符号的正则表达式
from RegExp regex, int pos
// 应用谓词检查条件
where has_unmatchable_dollar(regex, pos)
// 输出匹配结果及描述信息
select regex,
  "This regular expression includes an unmatchable dollar at offset " + pos.toString() + "."