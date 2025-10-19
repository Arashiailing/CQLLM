/**
 * @name Incomplete special group syntax in regular expression
 * @description Detects regular expressions with incomplete special group syntax,
 *              which are parsed as ordinary groups and likely fail to match intended patterns.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity high
 * @precision high
 * @id py/regex/incomplete-special-group
 */

import python  // Python语言分析模块，提供基础代码解析功能
import semmle.python.regex  // 正则表达式专用分析模块，支持模式匹配检测

// 查询定义：识别正则表达式中特殊组语法不完整的情况
from RegExp pattern, string absentCharacter, string groupName
where 
  // 检测正则表达式中存在命名组语法但缺少问号的情况
  exists(string text | text = pattern.getText() and text.regexpMatch(".*\\(P<\\w+>.*"))
  // 确定缺失的特定字符
  and absentCharacter = "?" 
  // 标识受影响的组类型
  and groupName = "named group"
// 输出结果：返回有问题的正则表达式并生成详细的警告信息
select pattern, "Regular expression is missing '" + absentCharacter + "' in " + groupName + "."