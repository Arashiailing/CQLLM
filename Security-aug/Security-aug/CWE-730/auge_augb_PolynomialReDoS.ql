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

// 引入Python分析核心模块
import python
// 引入多项式ReDoS安全分析模块，用于识别潜在的正则表达式性能问题
import semmle.python.security.dataflow.PolynomialReDoSQuery
// 引入路径图分析模块，用于追踪数据流路径
import PolynomialReDoSFlow::PathGraph

// 声明查询所需的数据流节点和正则表达式变量
from
  // 数据流路径的起始节点
  PolynomialReDoSFlow::PathNode sourceNode, 
  // 数据流路径的目标节点
  PolynomialReDoSFlow::PathNode destinationNode,
  // 正则表达式使用的接收器节点
  Sink sinkNode,
  // 存在回溯问题的正则表达式模式
  PolynomialBackTrackingTerm vulnerableRegex
// 设置查询条件，识别潜在的安全问题
where
  // 验证数据流路径的存在性
  PolynomialReDoSFlow::flowPath(sourceNode, destinationNode) and
  // 确保目标节点与接收器节点一致
  sinkNode = destinationNode.getNode() and
  // 从接收器节点中提取存在回溯问题的正则表达式
  vulnerableRegex = sinkNode.getABacktrackingTerm()
// 生成查询结果，包括警告信息和路径高亮
select
  // 高亮显示接收器节点位置
  sinkNode.getHighlight(), 
  // 数据流路径的起点和终点
  sourceNode, 
  destinationNode,
  // 构建详细的警告消息，说明潜在的性能风险
  "This $@ that depends on a $@ may run slow on strings " + vulnerableRegex.getPrefixMessage() +
    "with many repetitions of '" + vulnerableRegex.getPumpString() + "'.",
  // 标识存在问题的正则表达式对象
  vulnerableRegex, 
  "regular expression",
  // 标识用户提供的不可控数据源
  sourceNode.getNode(), 
  "user-provided value"