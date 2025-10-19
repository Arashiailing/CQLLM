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

// 导入Python语言支持库
import python
// 导入服务器端请求伪造安全分析模块
import semmle.python.security.dataflow.ServerSideRequestForgeryQuery
// 导入部分服务器端请求伪造数据流路径图类
import PartialServerSideRequestForgeryFlow::PathGraph

// 定义查询：识别部分受用户控制的HTTP请求，可能导致服务器端请求伪造漏洞
from
  PartialServerSideRequestForgeryFlow::PathNode originNode,  // 起始节点：表示用户输入的来源点
  PartialServerSideRequestForgeryFlow::PathNode targetNode,   // 目标节点：表示潜在的危险操作位置
  Http::Client::Request httpRequest                          // HTTP客户端请求对象
where
  // 确保当前HTTP请求是目标节点所关联的请求
  httpRequest = targetNode.getNode().(Sink).getRequest() and
  // 验证存在从起始节点到目标节点的数据流路径
  PartialServerSideRequestForgeryFlow::flowPath(originNode, targetNode) and
  // 排除完全受控的请求，专注于部分受控的情况
  not fullyControlledRequest(httpRequest)
select 
  httpRequest, originNode, targetNode, 
  "Part of the URL of this request depends on a $@.", 
  originNode.getNode(),
  "user-provided value"