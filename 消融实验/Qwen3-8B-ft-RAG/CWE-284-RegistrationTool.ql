/**
 * @name CWE-284: Improper Access Control
 * @description nan
 * @kind path-problem
 * @problem.severity recommendation
 * @id py/RegistrationTool
 */

// 导入Python库，用于分析Python代码
import python
// 导入与CWE-284相关的查询模块
import semmle.python.security.dataflow.Cwe284Query
// 导入路径图类，用于表示数据流路径
import Cwe284Flow::PathGraph
// 定义数据流源节点和汇节点的变量source和sink
from Cwe284Flow::PathNode source, Cwe284Flow::PathNode sink
// 使用where子句过滤出存在数据流路径的源节点和汇节点对
where Cwe284Flow::flowPath(source, sink)
// 选择符合条件的汇节点、源节点和汇节点，并生成相应的结果
select sink.getNode(), source, sink, "Insecure access control due to $@.", source.getNode(), "user-supplied value"