/**
 * @name CWE-400: Uncontrolled Resource Consumption
 * @description The product does not properly control the allocation and maintenance of a limited resource.
 * @kind path-problem
 * @id py/setup
 * @problem.severity error
 * @security-severity 7.5
 * @precision high
 * @tags security
 *       external/cwe/cwe-400
 */

// 导入必要的Python库
import python
// 导入TarSlip安全查询模块
import semmle.python.security.dataflow.TarSlipQuery
// 导入路径图类，用于表示数据流路径
import TarSlipFlow::PathGraph

// 从路径图中选择源节点和目标节点
from TarSlipFlow::PathNode source, TarSlipFlow::PathNode target
// 条件：如果存在从源节点到目标节点的路径流动
where TarSlipFlow::flowPath(source, target)
// 选择目标节点、源节点及路径信息，并生成警告信息
select target.getNode(), source, target, "This file extraction depends on a $@.", source.getNode(),  "user-provided value"