/**
 * @name Missing part of special group in regular expression
 * @description Incomplete special groups are parsed as normal groups and are unlikely to match the intended strings.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity high
 * @precision high
 * @id py/regex/incomplete-special-group
 */

import python
import semmle.python.regex

// 查找包含不完整命名组的正则表达式
from RegExp regexObj, string missingChar, string groupType
// 定义缺失的字符和组类型
where 
  missingChar = "?" and 
  groupType = "named group" and
  // 检查正则表达式文本是否包含类似"(P<word>"的模式，这表示可能缺少了开头的"?"
  exists(string regexText | 
    regexText = regexObj.getText() and 
    regexText.regexpMatch(".*\\(P<\\w+>.*")
  )
// 选择结果并生成警告信息
select regexObj, "Regular expression is missing '" + missingChar + "' in " + groupType + "."