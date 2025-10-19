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

import python  // 导入Python分析模块，提供基础代码分析能力
import semmle.python.regex  // 导入正则表达式专用分析模块，支持正则模式检测

// 查询定义：检测正则表达式中特殊组的不完整语法
from RegExp pattern, string expectedChar, string groupName
where 
  // 检测命名组语法中缺少问号的情况
  exists(string patternText | 
    patternText = pattern.getText() and
    patternText.regexpMatch(".*\\(P<\\w+>.*")
  )
  // 设置缺失的字符为问号
  and expectedChar = "?" 
  // 设置涉及的组类型为命名组
  and groupName = "named group"
// 输出结果：返回问题正则表达式并生成描述性警告信息
select pattern, "Regular expression is missing '" + expectedChar + "' in " + groupName + "."