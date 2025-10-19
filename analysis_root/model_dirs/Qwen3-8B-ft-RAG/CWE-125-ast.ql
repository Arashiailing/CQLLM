/**
 * @name Out-of-bounds read
 * @description The product reads data past the end, or before the beginning, of the intended buffer.
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 7.5
 * @sub-severity high
 * @precision high
 * @id py/ast
 */

import python
import semmle.python.security.dataflow.OutOfBoundsReadQuery
import semmle.python.pointsto.PointsTo
import semmle.python.ApiGraphs
import semmle.python.filters.Tests

// 定义数据流源节点和汇节点的变量
from OutOfBoundsReadFlow::PathNode source, OutOfBoundsReadFlow::PathNode sink, Value value, AstNode node
where
  // 条件：存在从源节点到汇节点的数据流路径
  OutOfBoundsReadFlow::flowPath(source, sink) and
  // 条件：获取汇节点所指向的值
  value = sink.getNode().getAValueReachableFrom(source.getNode()) and
  // 条件：确保该值不是测试代码中的
  not value = API::testsAny() and
  // 条件：确保该值不是测试代码中的
  not node = API::testsAny() and
  // 条件：获取汇节点本身
  node = sink.getNode()
// 选择结果：汇节点、源节点、汇节点、描述信息、源节点和描述信息
select node, source, sink, "This $@ is using an offset of $@ to access a buffer.", value, "value"