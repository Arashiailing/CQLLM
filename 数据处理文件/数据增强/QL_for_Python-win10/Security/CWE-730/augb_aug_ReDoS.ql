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

// 导入Python正则表达式树视图模块，用于分析正则表达式结构
private import semmle.python.regexp.RegexTreeView::RegexTreeView as TreeView
// 导入指数回溯检测模块，并使用TreeView作为参数实例化
import codeql.regex.nfa.ExponentialBackTracking::Make<TreeView>

// 定义查询变量：存在风险的正则表达式项、触发问题的重复模式、回溯状态和上下文信息
from TreeView::RegExpTerm vulnerableRegexTerm, string triggerPattern, State backtrackState, string contextInfo
where
  // 检查当前正则表达式项是否存在导致指数级回溯的潜在风险
  hasReDoSResult(vulnerableRegexTerm, triggerPattern, backtrackState, contextInfo) and
  // 排除详细模式（VERBOSE）的正则表达式，因为它们通常包含格式化空格和注释
  not vulnerableRegexTerm.getRegex().getAMode() = "VERBOSE"
select vulnerableRegexTerm,
  // 构建详细的警告消息，指出风险点和潜在影响
  "正则表达式的这部分可能在包含大量'" + triggerPattern + "'重复的字符串" + contextInfo +
    "上导致指数级回溯问题，从而引发性能瓶颈或拒绝服务攻击。"