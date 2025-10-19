/**
 * @name Incomplete special group syntax in regular expression
 * @description Regular expressions with incomplete special group syntax are parsed as normal groups,
 *              which may cause unexpected matching behavior.
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
from RegExp regexPattern, string missingSymbol, string specialGroupType
where 
  // 检测包含命名组语法但缺少问号的情况
  exists(string patternText | 
    patternText = regexPattern.getText() and
    patternText.regexpMatch(".*\\(P<\\w+>.*")
  )
  // 指定缺失的符号是问号
  and missingSymbol = "?" 
  // 指定涉及的组类型是命名组
  and specialGroupType = "named group"
// 输出结果：返回问题正则表达式并生成描述性警告信息
select regexPattern, "Regular expression is missing '" + missingSymbol + "' in " + specialGroupType + "."