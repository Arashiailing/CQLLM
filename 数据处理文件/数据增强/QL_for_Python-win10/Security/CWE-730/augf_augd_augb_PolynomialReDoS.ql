/**
 * @name 多项式时间复杂度正则表达式应用于不可控数据
 * @description 检测具有多项式时间复杂度的正则表达式在处理特定输入时可能导致拒绝服务攻击
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 7.5
 * @precision high
 * @id py/polynomial-redos
 * @tags security
 *       external/cwe/cwe-1333
 *       external/cwe/cwe-730
 *       external/cwe/cwe-400
 */

// 导入Python代码分析基础模块，提供Python语言分析的核心功能
import python
// 导入多项式ReDoS安全查询模块，用于识别正则表达式中的复杂度问题
import semmle.python.security.dataflow.PolynomialReDoSQuery
// 导入路径图模块，用于追踪数据流传播路径
import PolynomialReDoSFlow::PathGraph

// 定义查询所需的核心变量和组件
from
  // 存在回溯问题的正则表达式，可能导致性能问题
  PolynomialBackTrackingTerm regexWithBacktrackingIssue,
  // 数据流接收器节点，即正则表达式使用点
  Sink regexUsageLocation,
  // 数据流路径的起点，通常为用户输入源
  PolynomialReDoSFlow::PathNode inputSource,
  // 数据流路径的终点，即数据到达接收器的位置
  PolynomialReDoSFlow::PathNode dataDestination
// 设置查询条件，确保数据流路径存在且关联到易受攻击的正则表达式
where
  // 检查从输入源到目标节点的完整数据流路径
  PolynomialReDoSFlow::flowPath(inputSource, dataDestination) and
  // 确认目标节点与正则表达式使用位置对应
  regexUsageLocation = dataDestination.getNode() and
  // 从正则表达式使用位置中提取存在回溯问题的正则表达式
  regexWithBacktrackingIssue = regexUsageLocation.getABacktrackingTerm()
// 输出查询结果，包含路径信息和警告消息
select
  // 高亮显示正则表达式使用位置
  regexUsageLocation.getHighlight(), 
  inputSource, 
  dataDestination,
  // 构建详细的警告消息，说明潜在的性能风险
  "This $@ that depends on a $@ may run slow on strings " + 
  regexWithBacktrackingIssue.getPrefixMessage() +
  "with many repetitions of '" + regexWithBacktrackingIssue.getPumpString() + "'.",
  // 标识易受攻击的正则表达式对象
  regexWithBacktrackingIssue, 
  "regular expression",
  // 标识用户提供的输入源
  inputSource.getNode(), 
  "user-provided value"