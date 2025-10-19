/**
 * @name 低效正则表达式检测（ReDoS）
 * @description 识别可能导致指数级时间复杂度的正则表达式模式。
 *              这些模式在处理特定构造的输入时，会触发灾难性回溯，
 *              从而引发严重的性能问题和潜在的拒绝服务攻击。
 * @kind problem
 * @problem.severity error
 * @security-severity 7.5
 * @precision high
 * @id py/redos
 * @tags security
 *       external/cwe/cwe-1333
 *       external/cwe/cwe-730
 *       external/cwe/cwe-400
 */

// 引入Python正则表达式树结构视图模块，用于解析和分析正则表达式
private import semmle.python.regexp.RegexTreeView::RegexTreeView as TreeView
// 引入指数级回溯检测模块，使用TreeView作为参数进行实例化
import codeql.regex.nfa.ExponentialBackTracking::Make<TreeView>

// 定义查询的主要变量：存在安全风险的正则表达式项、触发问题的模式、回溯状态信息和上下文描述
from TreeView::RegExpTerm riskyRegExp, string problematicPattern, State backtrackingInfo, string additionalContext
where
  // 验证当前正则表达式项是否存在可能导致指数级回溯的安全隐患
  hasReDoSResult(riskyRegExp, problematicPattern, backtrackingInfo, additionalContext)
  and
  // 过滤掉使用详细模式（VERBOSE）的正则表达式，因为它们通常包含格式化的空白和注释
  not riskyRegExp.getRegex().getAMode() = "VERBOSE"
select riskyRegExp,
  // 生成详细的警告信息，指出具体的风险点和潜在的安全影响
  "正则表达式的这部分可能在包含大量'" + problematicPattern + "'重复的字符串" + additionalContext +
    "上导致指数级回溯问题，从而引发性能瓶颈或拒绝服务攻击。"