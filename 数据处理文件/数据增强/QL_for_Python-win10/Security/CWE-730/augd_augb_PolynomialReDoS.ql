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

// 引入Python代码分析基础模块
import python
// 引入多项式ReDoS安全查询模块，用于识别正则表达式中的复杂度问题
import semmle.python.security.dataflow.PolynomialReDoSQuery
// 引入路径图模块，用于追踪数据流传播路径
import PolynomialReDoSFlow::PathGraph

// 定义查询所需的核心变量和组件
from
  // 存在回溯问题的正则表达式，可能导致性能问题
  PolynomialBackTrackingTerm vulnerableRegex,
  // 数据流接收器节点，即正则表达式使用点
  Sink sinkNode,
  // 数据流路径的起点，通常为用户输入源
  PolynomialReDoSFlow::PathNode sourceNode,
  // 数据流路径的终点，即数据到达接收器的位置
  PolynomialReDoSFlow::PathNode destinationNode
// 设置查询条件，确保数据流路径存在且关联到易受攻击的正则表达式
where
  // 检查从源节点到目标节点的完整数据流路径
  PolynomialReDoSFlow::flowPath(sourceNode, destinationNode) and
  // 确认目标节点与接收器节点对应
  sinkNode = destinationNode.getNode() and
  // 从接收器节点中提取存在回溯问题的正则表达式
  vulnerableRegex = sinkNode.getABacktrackingTerm()
// 输出查询结果，包含路径信息和警告消息
select
  // 高亮显示接收器节点位置
  sinkNode.getHighlight(), sourceNode, destinationNode,
  // 构建详细的警告消息，说明潜在的性能风险
  "This $@ that depends on a $@ may run slow on strings " + vulnerableRegex.getPrefixMessage() +
    "with many repetitions of '" + vulnerableRegex.getPumpString() + "'.",
  // 标识易受攻击的正则表达式对象
  vulnerableRegex, "regular expression",
  // 标识用户提供的输入源
  sourceNode.getNode(), "user-provided value"