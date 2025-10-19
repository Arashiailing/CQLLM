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

// 检测正则表达式中无效美元符号位置的谓词
// 参数: regex - 待检查的正则表达式对象
//       offset - 美元符号在正则表达式中的位置偏移量
predicate contains_invalid_dollar(RegExp regex, int offset) {
  // 排除多行模式和详细模式（这两种模式可能改变$的含义）
  not (regex.getAMode() = "MULTILINE" or regex.getAMode() = "VERBOSE") and
  // 确认指定位置存在美元符号字符
  regex.specialCharacter(offset, offset + 1, "$") and
  // 验证该美元符号不在正则表达式的末尾位置
  not regex.lastItem(offset, offset + 1)
}

// 查询存在无效美元符号位置的正则表达式
from RegExp regex, int offset
// 应用谓词检测无效美元符号条件
where contains_invalid_dollar(regex, offset)
// 输出匹配结果及位置描述信息
select regex,
  "This regular expression includes an unmatchable dollar at offset " + offset.toString() + "."