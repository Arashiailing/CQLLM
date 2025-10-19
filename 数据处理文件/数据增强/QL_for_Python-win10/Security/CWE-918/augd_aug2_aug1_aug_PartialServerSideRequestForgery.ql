/**
 * @name Partial server-side request forgery
 * @description Identifies HTTP requests where URL components are influenced by untrusted external sources,
 *              potentially enabling server-side request forgery attacks
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.1
 * @precision medium
 * @id py/partial-ssrf
 * @tags security
 *       external/cwe/cwe-918
 */

// 导入Python标准库模块
import python
// 导入SSRF漏洞检测工具集
import semmle.python.security.dataflow.ServerSideRequestForgeryQuery
// 导入部分SSRF流分析路径图
import PartialServerSideRequestForgeryFlow::PathGraph

// 检测受外部输入影响的HTTP请求组件
from
  PartialServerSideRequestForgeryFlow::PathNode untrustedDataSourceNode,  // 非可信数据源节点
  PartialServerSideRequestForgeryFlow::PathNode vulnerableSinkNode,       // 潜在漏洞接收点
  Http::Client::Request httpRequest                                       // 目标HTTP请求对象
where
  // 验证数据流路径存在性
  PartialServerSideRequestForgeryFlow::flowPath(untrustedDataSourceNode, vulnerableSinkNode) and
  // 关联HTTP请求与漏洞接收点
  httpRequest = vulnerableSinkNode.getNode().(Sink).getRequest() and
  // 排除完全受控的请求场景
  not fullyControlledRequest(httpRequest)
select httpRequest, untrustedDataSourceNode, vulnerableSinkNode, "URL component in this request originates from $@.", untrustedDataSourceNode.getNode(),
  "user-provided input"