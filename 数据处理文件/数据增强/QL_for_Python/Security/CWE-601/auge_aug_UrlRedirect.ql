/**
 * @name URL redirection from remote source
 * @description URL redirection based on unvalidated user input
 *              may cause redirection to malicious web sites.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 6.1
 * @sub-severity low
 * @id py/url-redirection
 * @tags security
 *       external/cwe/cwe-601
 * @precision high
 */

// 引入Python语言分析支持库
import python

// 引入URL重定向安全数据流分析模块
import semmle.python.security.dataflow.UrlRedirectQuery

// 引入数据流路径图可视化模块
import UrlRedirectFlow::PathGraph

// 查询主体：检测未经验证的URL重定向漏洞路径
from UrlRedirectFlow::PathNode inputOriginNode, UrlRedirectFlow::PathNode redirectTargetNode
where 
  // 确保存在从不可信输入源到重定向目标的数据流路径
  UrlRedirectFlow::flowPath(inputOriginNode, redirectTargetNode)
select 
  // 输出重定向目标位置作为主要结果
  redirectTargetNode.getNode(), 
  // 输出完整数据流路径用于可视化展示
  inputOriginNode, redirectTargetNode, 
  // 提供描述性消息，标识漏洞依赖的输入源
  "Untrusted URL redirection depends on a $@.", 
  inputOriginNode.getNode(), 
  "user-provided value"