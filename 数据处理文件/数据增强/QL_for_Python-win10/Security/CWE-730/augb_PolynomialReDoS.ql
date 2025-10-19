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

// 导入Python模块以支持代码分析
import python
// 导入多项式ReDoS查询模块，用于检测多项式复杂度的正则表达式安全问题
import semmle.python.security.dataflow.PolynomialReDoSQuery
// 导入路径图模块，用于分析数据流路径
import PolynomialReDoSFlow::PathGraph

// 定义查询所需的数据源和变量
from
  // 定义数据流路径的起点和终点
  PolynomialReDoSFlow::PathNode originNode, PolynomialReDoSFlow::PathNode targetNode,
  // 定义接收器节点
  Sink receiverNode,
  // 定义存在回溯问题的正则表达式
  PolynomialBackTrackingTerm problematicRegex
// 查询条件定义
where
  // 检查是否存在从起点到终点的数据流路径
  PolynomialReDoSFlow::flowPath(originNode, targetNode) and
  // 确保目标节点与接收器节点匹配
  receiverNode = targetNode.getNode() and
  // 获取接收器节点中的回溯项正则表达式
  problematicRegex = receiverNode.getABacktrackingTerm()
// 输出查询结果
select
  // 高亮显示接收器节点、起点和终点
  receiverNode.getHighlight(), originNode, targetNode,
  // 构建警告消息，描述潜在的性能问题
  "This $@ that depends on a $@ may run slow on strings " + problematicRegex.getPrefixMessage() +
    "with many repetitions of '" + problematicRegex.getPumpString() + "'.",
  // 标识正则表达式对象及其描述
  problematicRegex, "regular expression",
  // 标识源节点对象及其描述
  originNode.getNode(), "user-provided value"