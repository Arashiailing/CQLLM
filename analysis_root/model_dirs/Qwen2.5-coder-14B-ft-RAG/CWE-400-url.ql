/**
 * @name CWE-400: Uncontrolled Resource Consumption
 * @description The product does not properly control the allocation and maintenance of a limited resource.
 * @kind path-problem
 * @id py/url
 * @problem.severity error
 * @precision high
 * @security-severity 7.5
 * @tags security
 *       external/cwe/cwe-400
 */

// 导入Python库，用于分析Python代码
import python

// 导入URL重定向查询模块，用于检测URL重定向安全问题
import semmle.python.security.dataflow.UrlRedirectQuery

// 导入路径图类，用于表示数据流路径
import UrlRedirectFlow::PathGraph

// 从路径图中选择源节点和汇节点
from UrlRedirectFlow::PathNode source, UrlRedirectFlow::PathNode sink

// 条件：存在从源节点到汇节点的路径
where UrlRedirectFlow::flowPath(source, sink)

// 选择结果：汇节点、源节点、汇节点信息、描述信息、源节点信息、用户输入值
select sink.getNode(), source, sink,
  "URL redirect depends on a $@.", source.getNode(), "user-provided value"