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
from RegExp regexPattern, string missingCharacter, string specialGroupType
where 
  // 识别正则表达式文本中包含命名组语法但缺少问号的情况
  // 模式解释：查找包含 \(P<单词字符> 结构的正则表达式
  exists(string patternText | 
    patternText = regexPattern.getText() and 
    patternText.regexpMatch(".*\\(P<\\w+>.*")
  )
  // 指定缺失的字符是问号
  and missingCharacter = "?" 
  // 指定涉及的组类型是命名组
  and specialGroupType = "named group"
// 输出结果：返回问题正则表达式并生成描述性警告信息
select regexPattern, "Regular expression is missing '" + missingCharacter + "' in " + specialGroupType + "."