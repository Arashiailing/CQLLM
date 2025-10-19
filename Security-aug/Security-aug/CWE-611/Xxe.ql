/**
 * @name XML external entity expansion
 * @description Parsing user input as an XML document with external
 *              entity expansion is vulnerable to XXE attacks.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.1
 * @precision high
 * @id py/xxe
 * @tags security
 *       external/cwe/cwe-611
 *       external/cwe/cwe-827
 */

// 导入Python库，用于处理Python代码的解析和分析
import python

// 导入与XXE攻击相关的查询模块
import semmle.python.security.dataflow.XxeQuery

// 导入路径图类，用于表示数据流路径
import XxeFlow::PathGraph

// 定义数据流源节点和汇节点
from XxeFlow::PathNode source, XxeFlow::PathNode sink

// 条件：存在从源节点到汇节点的数据流路径
where XxeFlow::flowPath(source, sink)

// 选择汇节点、源节点、汇节点信息，并生成警告信息
select sink.getNode(), source, sink,
  "XML parsing depends on a $@ without guarding against external entity expansion.", // 警告信息：未防范外部实体扩展的XML解析
  source.getNode(), "user-provided value" // 源节点信息及用户输入值标签
