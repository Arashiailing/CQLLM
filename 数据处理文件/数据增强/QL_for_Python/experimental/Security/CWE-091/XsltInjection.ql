/**
 * @name XSLT query built from user-controlled sources
 * @description Building a XSLT query from user-controlled sources is vulnerable to insertion of
 *              malicious XSLT code by the user.
 * @kind path-problem
 * @problem.severity error
 * @precision high
 * @id py/xslt-injection
 * @tags security
 *       experimental
 *       external/cwe/cwe-643
 */

// 导入Python库，用于处理Python代码的解析和分析
import python

// 导入XSLT注入查询模块，用于检测XSLT注入漏洞
import XsltInjectionQuery

// 导入XSLT注入路径图模块，用于构建数据流路径图
import XsltInjectionFlow::PathGraph

// 定义数据流源节点和汇节点
from XsltInjectionFlow::PathNode source, XsltInjectionFlow::PathNode sink

// 条件：存在从源节点到汇节点的数据流路径
where XsltInjectionFlow::flowPath(source, sink)

// 选择汇节点、源节点和汇节点信息，并生成警告信息
select sink.getNode(), source, sink, "This XSLT query depends on $@.", source.getNode(),
  "user-provided value"
