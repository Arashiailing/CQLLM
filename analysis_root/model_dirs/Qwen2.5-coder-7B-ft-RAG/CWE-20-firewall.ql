/**
 * @name CWE-20: Improper Input Validation
 * @description The product receives input or data, but it does
 *              not validate or incorrectly validates that the input has the
 *              properties that are required to process the data safely and
 *              correctly.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.5
 * @precision high
 * @id py/firewall
 * @tags security
 *       external/cwe/cwe-20
 */

// 导入Python库，用于分析Python代码
import python

// 导入防火墙安全分析模块，用于检测潜在的安全风险
import semmle.python.security.FirewallQuery

// 导入路径图类，用于表示数据流路径
import FirewallFlow::PathGraph

// 从路径图中选择源节点和汇节点
from FirewallFlow::PathNode source, FirewallFlow::PathNode sink

// 条件：存在从源节点到汇节点的数据流路径
where FirewallFlow::flowPath(source, sink)

// 选择汇节点、源节点、路径信息以及描述信息
select sink.getNode(), source, sink, "Firewall rule bypasses validation check for $@", source.getNode(),
  "user-supplied data"