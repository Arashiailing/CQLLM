/**
 * @name CWE-918: Server-Side Request Forgery (SSRF)
 * @description Partial server-side request forgery.Making a network request to a URL that is partially user-controlled allows for request forgery attacks..
 *              The web server receives a URL or similar request from an upstream component and retrieves the contents of this URL, but it does not sufficiently ensure that the request is being sent to the expected destination.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.1
 * @precision medium
 * @id py/ssrf
 * @tags security
 *       external/cwe/cwe-918
 */

// 导入Python语言支持
import python
// 导入服务器端请求伪造安全查询模块
import semmle.python.security.dataflow.ServerSideRequestForgeryQuery
// 导入部分服务器端请求伪造流路径图模块
import PartialServerSideRequestForgeryFlow::PathGraph

// 定义查询变量：源节点、汇节点、HTTP客户端请求
from PartialServerSideRequestForgeryFlow::PathNode source, PartialServerSideRequestForgeryFlow::PathNode sink, Http::Client::Request request
// 连接条件：请求对应汇节点的请求对象，且存在从源到汇的流路径，且请求未完全受控
where
  request = sink.getNode().(Sink).getRequest() and
  PartialServerSideRequestForgeryFlow::flowPath(source, sink) and
  not fullyControlledRequest(request)
// 选择结果：请求、源节点、汇节点、描述信息、源节点、用户输入值描述
select request, source, sink, "Part of the URL of this request depends on a $@.", source.getNode(), "user-provided value"