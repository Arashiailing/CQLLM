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

// 定义一个谓词函数，用于判断正则表达式中是否存在无法匹配的美元符号
predicate unmatchable_dollar(RegExp r, int start) {
  // 检查正则表达式的模式是否不是多行模式
  not r.getAMode() = "MULTILINE" and
  // 检查正则表达式的模式是否不是详细模式
  not r.getAMode() = "VERBOSE" and
  // 检查在指定位置是否有特殊字符'$'
  r.specialCharacter(start, start + 1, "$") and
  // 检查该位置是否是正则表达式的最后一个元素
  not r.lastItem(start, start + 1)
}

// 从正则表达式和偏移量开始查询
from RegExp r, int offset
// 条件是存在无法匹配的美元符号
where unmatchable_dollar(r, offset)
// 选择正则表达式和描述信息
select r,
  "This regular expression includes an unmatchable dollar at offset " + offset.toString() + "."
