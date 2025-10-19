/**
 * @name CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
 * @description nan
 * @kind path-problem
 * @problem.severity recommendation
 * @id py/ZODBRoleManager
 */

import python
import semmle.python.dataflow.new.DataFlow
import ZODBFlow::PathGraph
import semmle.python.ApiGraphs
import semmle.python.filters.Tests
import semmle.python.filters.RegisteredModules

// 定义数据流源节点和汇节点
from ZODBFlow::PathNode source, ZODBFlow::PathNode sink
// 条件：存在从源节点到汇节点的数据流路径
where ZODBFlow::flowPath(source, sink)
// 选择结果：汇节点、源节点、路径信息以及描述信息
select sink.getNode(), source, sink, "This $@ depends on a $@.", source.getNode(),
  "user-provided value", "user-supplied value"