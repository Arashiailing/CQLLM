/**
 * @name Polynomial regular expression used on uncontrolled data
 * @description A regular expression that can require polynomial time
 *              to match may be vulnerable to denial-of-service attacks.
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

// 导入Python库
import python
// 导入PolynomialReDoSQuery模块，用于检测多项式复杂度的正则表达式问题
import semmle.python.security.dataflow.PolynomialReDoSQuery
// 导入PathGraph类，用于路径图分析
import PolynomialReDoSFlow::PathGraph

// 从以下数据源中选择数据
from
  // 定义源节点和汇节点，类型为PathNode
  PolynomialReDoSFlow::PathNode source, PolynomialReDoSFlow::PathNode sink, 
  // 定义Sink类型的汇节点
  Sink sinkNode,
  // 定义一个表示回溯项的正则表达式对象
  PolynomialBackTrackingTerm regexp
where
  // 条件：存在从源节点到汇节点的数据流路径
  PolynomialReDoSFlow::flowPath(source, sink) and
  // 条件：汇节点与Sink对象匹配
  sinkNode = sink.getNode() and
  // 条件：获取汇节点中的回溯项正则表达式
  regexp = sinkNode.getABacktrackingTerm()
// 注释掉的条件：源节点不是URL且正则表达式在行尾
//   not (
//     source.getNode().(Source).getKind() = "url" and
//     regexp.isAtEndLine()
//   )
select 
  // 选择要高亮显示的汇节点、源节点、汇节点
  sinkNode.getHighlight(), source, sink,
  // 选择消息字符串，描述潜在的性能问题
  "This $@ that depends on a $@ may run slow on strings " + regexp.getPrefixMessage() +
    "with many repetitions of '" + regexp.getPumpString() + "'.", 
  // 选择正则表达式对象和其描述
  regexp, "regular expression",
  // 选择源节点对象及其描述
  source.getNode(), "user-provided value"
