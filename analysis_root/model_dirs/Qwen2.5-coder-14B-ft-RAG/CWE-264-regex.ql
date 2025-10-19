/**
 * @name Regular Expression Handling Using User Input
 * @description Using user-controlled input to construct regular expressions may allow an attacker to
 *              perform a Denial of Service (DoS) attack via ReDoS.
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

// 导入Python基础库
import python
// 导入正则表达式安全查询模块
import semmle.python.security.dataflow.PolynomialReDoSQuery
// 导入路径图模块，用于表示数据流路径
import PolynomialReDoSFlow::PathGraph

// 定义数据流源节点和汇节点的变量
from PolynomialReDoSFlow::PathNode source, PolynomialReDoSFlow::PathNode sink,
     // 定义Sink类型的汇节点
     Sink sinkNode,
     // 定义一个表示回溯项的正则表达式对象
     PolynomialBackTrackingTerm regexp
where
  // 条件：存在从源节点到汇节点的数据流路径
  PolynomialReDoSFlow::flowPath(source, sink) and
  // 条件：汇节点属于Sink类型
  sinkNode = sink.getNode() and
  // 条件：获取汇节点对应的正则表达式对象
  regexp = sinkNode.(Sink).getABacktrackingTerm()
// 选择结果：汇节点、源节点、路径信息、正则表达式信息以及描述信息
select sinkNode, source, sink, "This regex term ($@) depends on a $@.", regexp, "backtracking pattern",
  source.getNode(), "user-provided value"