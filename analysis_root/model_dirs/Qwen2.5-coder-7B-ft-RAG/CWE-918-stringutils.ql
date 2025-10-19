/**
 * @name CWE-918: Server-Side Request Forgery (SSRF)
 * @description Partial server-side request forgery. Making a network request to a URL that is partially user-controlled allows for request forgery attacks.
 *              The web server receives a URL or similar request from an upstream component and retrieves the contents of this URL,
 *              but it does not sufficiently ensure that the request is being sent to the expected destination.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.1
 * @precision medium
 * @id py/partial-ssrf
 * @tags security
 *       external/cwe/cwe-918
 */

// 导入Python库，用于分析Python代码
import python

// 导入部分服务器端请求伪造查询模块
import semmle.python.security.dataflow.ServerSideRequestForgeryQuery

// 导入部分服务器端请求伪造流路径图类
import PartialServerSideRequestForgeryFlow::PathGraph

// 从部分服务器端请求伪造流路径图中选择源节点和汇节点，以及HTTP客户端请求
from  
  PartialServerSideRequestForgeryFlow::PathNode source, // 源节点
  PartialServerSideRequestForgeryFlow::PathNode sink,   // 汇节点
  Http::Client::Request request                         // HTTP客户端请求

// 条件：请求是汇节点的请求，并且存在从源到汇的流路径，且请求未完全受控
where  
  request = sink.getNode().(Sink).getRequest() and       // 获取汇节点的请求
  PartialServerSideRequestForgeryFlow::flowPath(source, sink) and // 检查是否存在从源到汇的流路径
  not fullyControlledRequest(request)                   // 检查请求是否未完全受控

// 选择结果：汇节点、源节点、汇节点、警告信息、源节点、用户输入值描述
select request, source, sink, 
  "Part of the URL of this request depends on a $@.", 
  source.getNode(),  // 源节点
  "user-provided value"                                // 用户输入值描述