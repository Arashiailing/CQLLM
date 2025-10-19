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

// 导入Python库，用于分析Python代码
import python

// 导入与URL重定向相关的安全数据流查询模块
import semmle.python.security.dataflow.UrlRedirectQuery

// 从UrlRedirectFlow模块中导入PathGraph类，用于表示路径图
import UrlRedirectFlow::PathGraph

// 定义一个查询，查找URL重定向的源节点和目标节点
from UrlRedirectFlow::PathNode source, UrlRedirectFlow::PathNode sink
where UrlRedirectFlow::flowPath(source, sink) // 条件：存在从源节点到目标节点的路径
select sink.getNode(), source, sink, "Untrusted URL redirection depends on a $@.", source.getNode(),
  "user-provided value" // 选择目标节点、源节点、路径以及相关信息进行输出
