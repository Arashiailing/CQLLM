/**
 * @name Unmatchable dollar in regular expression
 * @description A regular expression that has a dollar sign '$' in a non-terminal position will never match any input string.
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

// 检测包含非末尾美元符号的正则表达式（导致无法匹配任何输入）
predicate containsUnmatchableDollar(RegExp regexPattern, int dollarOffset) {
  // 验证指定位置存在美元符号字符
  regexPattern.specialCharacter(dollarOffset, dollarOffset + 1, "$") and
  // 确认美元符号不在正则表达式末尾位置
  not regexPattern.lastItem(dollarOffset, dollarOffset + 1) and
  // 确保未启用影响'$'行为的特殊模式
  not (regexPattern.getAMode() = "MULTILINE" or regexPattern.getAMode() = "VERBOSE")
}

// 查询包含问题美元符号的正则表达式
from RegExp regexPattern, int dollarOffset
where containsUnmatchableDollar(regexPattern, dollarOffset)
select regexPattern,
  "This regular expression includes an unmatchable dollar at offset " + dollarOffset.toString() + "."