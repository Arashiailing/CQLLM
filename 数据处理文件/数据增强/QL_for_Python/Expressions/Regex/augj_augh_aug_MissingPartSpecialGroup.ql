/**
 * @name Incomplete special group syntax in regular expression
 * @description Detects incomplete special group syntax in regular expressions,
 *              which are parsed as normal groups and may not match intended strings.
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
from RegExp regexPattern, string missingCharacter, string groupType
where 
  exists(string patternContent | 
    patternContent = regexPattern.getText() and
    // 检测命名组语法中缺少问号的情况
    patternContent.regexpMatch(".*\\(P<\\w+>.*")
  )
  // 设置缺失的字符为问号
  and missingCharacter = "?" 
  // 设置涉及的组类型为命名组
  and groupType = "named group"
// 输出结果：返回问题正则表达式并生成描述性警告信息
select regexPattern, "Regular expression is missing '" + missingCharacter + "' in " + groupType + "."