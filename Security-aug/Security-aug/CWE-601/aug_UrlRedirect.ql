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

// 导入Python分析核心库
import python

// 导入URL重定向安全数据流分析模块
import semmle.python.security.dataflow.UrlRedirectQuery

// 导入路径图表示模块
import UrlRedirectFlow::PathGraph

// 查询定义：识别未经验证的URL重定向路径
from UrlRedirectFlow::PathNode sourceNode, UrlRedirectFlow::PathNode sinkNode
where 
  // 存在从用户输入源到重定向目标的数据流路径
  UrlRedirectFlow::flowPath(sourceNode, sinkNode)
select 
  // 输出重定向目标位置
  sinkNode.getNode(), 
  // 输出完整数据流路径
  sourceNode, sinkNode, 
  // 描述性消息，标注用户输入源
  "Untrusted URL redirection depends on a $@.", 
  sourceNode.getNode(), 
  "user-provided value"