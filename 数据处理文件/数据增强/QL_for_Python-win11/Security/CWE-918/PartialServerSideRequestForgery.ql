/**
 * @name Partial server-side request forgery
 * @description Making a network request to a URL that is partially user-controlled allows for request forgery attacks.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.1
 * @precision medium
 * @id py/partial-ssrf
 * @tags security
 *       external/cwe/cwe-918
 */

// 导入Python库
import python
// 导入服务器端请求伪造查询模块
import semmle.python.security.dataflow.ServerSideRequestForgeryQuery
// 导入部分服务器端请求伪造流路径图类
import PartialServerSideRequestForgeryFlow::PathGraph

// 从部分服务器端请求伪造流路径图中选择源节点和汇节点，以及HTTP客户端请求
from
  PartialServerSideRequestForgeryFlow::PathNode source, // 源节点
  PartialServerSideRequestForgeryFlow::PathNode sink,   // 汇节点
  Http::Client::Request request                         // HTTP客户端请求
where
  // 条件：请求是汇节点的请求，并且存在从源到汇的流路径，且请求未完全受控
  request = sink.getNode().(Sink).getRequest() and       // 获取汇节点的请求
  PartialServerSideRequestForgeryFlow::flowPath(source, sink) and // 检查是否存在从源到汇的流路径
  not fullyControlledRequest(request)                   // 检查请求是否未完全受控
select request, source, sink, "Part of the URL of this request depends on a $@.", source.getNode(),
  "user-provided value"                                // 选择请求、源节点、汇节点，并生成警告信息，指出URL的一部分依赖于用户提供的值
