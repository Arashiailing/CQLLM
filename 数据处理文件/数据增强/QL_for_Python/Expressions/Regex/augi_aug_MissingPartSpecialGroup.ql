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
from RegExp problematicPattern, string missingCharacter, string groupCategory

// 检测条件：识别不完整的命名组语法
where 
  // 检测正则表达式中存在不完整的命名组模式（缺少问号）
  problematicPattern.getText().regexpMatch(".*\\(P<\\w+>.*") 
  // 指定缺失的必需字符是问号
  and missingCharacter = "?" 
  // 指定涉及的组类型是命名组
  and groupCategory = "named group"

// 输出结果：返回问题正则表达式并生成描述性警告信息
select problematicPattern, "Regular expression is missing '" + missingCharacter + "' in " + groupCategory + "."