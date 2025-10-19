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

// 识别包含非末尾美元符号的正则表达式（无法匹配任何输入）
predicate hasUnmatchableDollar(RegExp pattern, int charOffset) {
  // 确保未启用影响'$'行为的特殊模式
  not (pattern.getAMode() = "MULTILINE" or pattern.getAMode() = "VERBOSE") and
  // 验证指定位置存在美元符号字符
  pattern.specialCharacter(charOffset, charOffset + 1, "$") and
  // 确认美元符号不在正则表达式末尾位置
  not pattern.lastItem(charOffset, charOffset + 1)
}

// 查询包含问题美元符号的正则表达式
from RegExp regexPattern, int dollarOffset
where hasUnmatchableDollar(regexPattern, dollarOffset)
select regexPattern,
  "This regular expression includes an unmatchable dollar at offset " + dollarOffset.toString() + "."