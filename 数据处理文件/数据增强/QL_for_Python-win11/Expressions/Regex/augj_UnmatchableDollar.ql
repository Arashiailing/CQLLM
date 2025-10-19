/**
 * @name Unmatchable dollar in regular expression
 * @description Identifies regular expressions containing a dollar '$' symbol that cannot be matched,
 *              regardless of the input string, because it appears in the middle of the pattern
 *              rather than at the end.
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

// 定义谓词函数，用于检测正则表达式中是否存在无法匹配的美元符号
predicate has_unmatchable_dollar(RegExp regexExpr, int position) {
  // 首先确保正则表达式不在多行模式下（在多行模式下，$匹配每行的结尾）
  not regexExpr.getAMode() = "MULTILINE" and
  // 确保正则表达式也不在详细模式下（详细模式允许空白和注释）
  not regexExpr.getAMode() = "VERBOSE" and
  // 检查在指定位置是否存在美元符号'$'特殊字符
  regexExpr.specialCharacter(position, position + 1, "$") and
  // 确认该美元符号不是正则表达式的最后一个元素（否则它是可匹配的）
  not regexExpr.lastItem(position, position + 1)
}

// 查询所有包含无法匹配美元符号的正则表达式
from RegExp regexExpr, int charPosition
// 应用谓词函数检查是否存在无法匹配的美元符号
where has_unmatchable_dollar(regexExpr, charPosition)
// 输出结果，包括正则表达式对象和描述信息
select regexExpr,
  "This regular expression includes an unmatchable dollar at offset " + charPosition.toString() + "."