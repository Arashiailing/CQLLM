/**
 * @name CWE-400: Uncontrolled Resource Consumption
 * @description The product does not properly control the allocation and maintenance of a limited resource.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.5
 * @sub-severity high
 * @precision high
 * @id py/tls
 * @tags security
 *       external/cwe/cwe-400
 */

// 导入必要的Python分析库
import python
// 导入TLS安全数据流分析模块
import semmle.python.security.dataflow.TLSQuery
// 导入路径图类，用于表示数据流路径
import TLSFlow::PathGraph

// 从路径图中选择源节点和汇节点
from TLSFlow::PathNode source, TLSFlow::PathNode sink
// 条件：如果存在从源节点到汇节点的路径流动
where TLSFlow::flowPath(source, sink)
// 选择汇节点、源节点、汇点节点，并生成警告信息
select sink.getNode(), source, sink,
  "This TLS connection depends on a $@.", source.getNode(), "user-provided value"