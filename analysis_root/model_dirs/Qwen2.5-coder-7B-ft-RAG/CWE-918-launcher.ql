/**
 * @name Full server-side request forgery
 * @description Making a network request to a URL that is fully user-controlled allows for request forgery attacks.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.1
 * @precision high
 * @id py/full-ssrf
 * @tags security
 *       external/cwe/cwe-918
 */
import python
import semmle.python.security.dataflow.ServerSideRequestForgeryQuery
import FullServerSideRequestForgeryFlow::PathGraph
from
  // 源路径节点
  FullServerSideRequestForgeryFlow::PathNode source,
  // 目标路径节点
  FullServerSideRequestForgeryFlow::PathNode sink,
  // HTTP客户端请求
  Http::Client::Request request
where
  // 将请求与目标节点的请求进行匹配
  request = sink.getNode().(Sink).getRequest() and
  // 检查是否存在从源到目标的流动路径
  FullServerSideRequestForgeryFlow::flowPath(source, sink) and
  // 检查请求是否完全受用户控制
  fullyControlledRequest(request)
select
  // 选择请求、源节点和目标节点
  request, source, sink,
  // 输出消息，说明请求的完整URL依赖于某个用户输入的值
  "The full URL of this request depends on a $@.", source.getNode(),
  "user-provided value"