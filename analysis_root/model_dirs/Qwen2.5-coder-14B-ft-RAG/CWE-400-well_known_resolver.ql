/**
 * @name CWE-400: Server-Side Request Forgery
 * @description An HTTP request (or redirect) is constructed based on user-controlled input and sent to another system.
 *              This could allow an attacker to send requests to internal systems within the organization's network.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 8.8
 * @precision high
 * @id py/server-side-request-forgery
 * @tags correctness
 *       security
 *       external/cwe/cwe-918
 */

// 导入Python库，用于分析Python代码
import python
// 导入服务器端请求伪造查询模块，用于检测服务器端请求伪造漏洞
import semmle.python.security.dataflow.ServerSideRequestForgeryQuery
// 导入服务器端请求伪造流路径图类，用于表示数据流路径
import ServerSideRequestForgeryFlow::PathGraph

// 从服务器端请求伪造流路径图中选择源节点和汇节点
from
  ServerSideRequestForgeryFlow::PathNode source,
  ServerSideRequestForgeryFlow::PathNode sink
// 条件：存在从源节点到汇节点的数据流路径
where
  ServerSideRequestForgeryFlow::flowPath(source, sink)
// 选择汇节点、源节点及其相关信息，并生成警告信息
select sink.getNode(), source, sink, "This request depends on a $@.", source.getNode(), "user-provided value"