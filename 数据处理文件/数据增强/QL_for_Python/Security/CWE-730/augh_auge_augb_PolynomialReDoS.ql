/**
 * @name 多项式时间复杂度正则表达式应用于不可控数据
 * @description 具有多项式时间复杂度的正则表达式在处理特定输入时可能导致拒绝服务攻击。
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

// 导入Python分析核心模块，提供基础Python代码分析能力
import python
// 导入多项式ReDoS安全分析模块，用于检测正则表达式中的潜在性能问题
import semmle.python.security.dataflow.PolynomialReDoSQuery
// 导入路径图分析模块，用于可视化和追踪数据流路径
import PolynomialReDoSFlow::PathGraph

// 定义查询所需的数据流节点和正则表达式变量
from
  // 数据流路径的起始节点，表示用户输入的源头
  PolynomialReDoSFlow::PathNode entryNode, 
  // 数据流路径的结束节点，表示数据最终到达的位置
  PolynomialReDoSFlow::PathNode exitNode,
  // 正则表达式使用的接收器节点，表示正则表达式应用点
  Sink regexSinkNode,
  // 存在回溯问题的正则表达式模式，可能导致性能问题
  PolynomialBackTrackingTerm problematicRegex
// 设置查询条件，识别潜在的安全风险
where
  // 检查是否存在从入口节点到出口节点的数据流路径
  PolynomialReDoSFlow::flowPath(entryNode, exitNode) and
  // 确保出口节点与正则表达式接收器节点匹配
  regexSinkNode = exitNode.getNode() and
  // 从接收器节点中提取存在回溯问题的正则表达式
  problematicRegex = regexSinkNode.getABacktrackingTerm()
// 生成查询结果，包括警告信息和数据流路径
select
  // 高亮显示正则表达式接收器节点的位置
  regexSinkNode.getHighlight(), 
  // 数据流路径的起点和终点，用于可视化
  entryNode, 
  exitNode,
  // 构建详细的警告消息，说明潜在的性能风险
  "This $@ that depends on a $@ may run slow on strings " + problematicRegex.getPrefixMessage() +
    "with many repetitions of '" + problematicRegex.getPumpString() + "'.",
  // 标识存在问题的正则表达式对象
  problematicRegex, 
  "regular expression",
  // 标识用户提供的不可控数据源
  entryNode.getNode(), 
  "user-provided value"