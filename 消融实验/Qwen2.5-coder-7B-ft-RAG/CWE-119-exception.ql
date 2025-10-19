/**
 * @name CWE-119: Improper Restriction of Operations within the Bounds of a Memory Buffer
 * @description The product performs operations on a memory buffer, but it reads from or writes to a memory location outside
 *              the buffer's intended boundary. This may result in read or write operations on unexpected memory locations
 *              that could be linked to other variables, data structures, or internal program data.
 * @kind problem
 * @problem.severity error
 * @security-severity 6.1
 * @precision medium
 * @id py/memory-buffer-boundary-check-failure
 * @tags security
 *       external/cwe/cwe-119
 */

// 导入必要的模块
import python
import semmle.python.security.dataflow.MemoryBufferBoundCheckFailureQuery
import MemoryBufferBoundCheckFailureFlow::PathGraph

// 定义数据流源节点和汇节点
from MemoryBufferBoundCheckFailureFlow::PathNode source, MemoryBufferBoundCheckFailureFlow::PathNode sink

// 过滤出存在数据流路径的情况
where MemoryBufferBoundCheckFailureFlow::flowPath(source, sink)

// 选择结果：汇节点、源节点、路径信息、描述信息等
select sink.getNode(), source, sink,
  "Memory buffer access at $@ relies on a $@.", source.getNode(),
  "user-controlled value", sink.getNode(), "calculated index"