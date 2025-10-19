/**
 * @name CWE-119: Improper Restriction of Operations within the Bounds of a Memory Buffer
 * @description The product performs operations on a memory buffer, but it reads from or writes to a memory location outside the buffer's intended boundary.
 *              This may result in read or write operations on unexpected memory locations that could be linked to other variables, data structures,
 *              or internal program data.
 * @kind path-problem
 * @problem.severity error
 * @precision high
 * @security-severity 9.1
 * @id py/core-cwe-119
 * @tags correctness
 *       security
 *       external/cwe/cwe-119
 */

// 导入Python库，用于分析Python代码
import python

// 导入路径注入查询模块，用于检测路径注入问题
import semmle.python.security.dataflow.PathInjectionQuery

// 从路径注入流中导入路径节点类
import PathInjectionFlow::PathGraph

// 定义数据流源和汇点
from PathInjectionFlow::PathNode source, PathInjectionFlow::PathNode sink

// 条件：如果存在从源到汇的路径流动
where PathInjectionFlow::flowPath(source, sink)

// 选择汇点节点、源节点、汇点节点，并生成警告信息
select sink.getNode(), source, sink, "Call to " + externalApi.toString() + " with untrusted data from $@.", source.getNode(),  
       source.toString()