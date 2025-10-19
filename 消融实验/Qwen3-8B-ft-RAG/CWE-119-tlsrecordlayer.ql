/**
 * @name Improper restriction of operations within the bounds of a memory buffer
 * @description The product performs operations on a memory buffer, but it reads from or writes to a memory location outside the buffer's intended boundary. This may result in read or write operations on unexpected memory locations that could be linked to other variables, data structures, or internal program data.
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 7.8
 * @sub-severity low
 * @precision high
 * @tags reliability
 *       external/cwe/cwe-120
 *       external/cwe/cwe-119
 * @id py/tlsrecordlayer
 */

// 导入Python库，用于分析Python代码
import python

// 导入与不安全反序列化相关的查询模块，用于检测不安全的反序列化操作
import semmle.python.security.dataflow.UnsafeDeserializationQuery

// 导入路径图模块，用于表示数据流路径，帮助追踪数据流的起点和终点
import UnsafeDeserializationFlow::PathGraph

// 定义查询，查找不安全反序列化的数据流路径
from UnsafeDeserializationFlow::PathNode source, UnsafeDeserializationFlow::PathNode sink
where UnsafeDeserializationFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Unsafe deserialization depends on a $@.", source.getNode(), "user-provided value"