/**
 * @name CWE-20: Improper Input Validation
 * @description The product receives input or data, but it does
 *              not validate or incorrectly validates that the input has the
 *              properties that are required to process the data safely and
 *              correctly.
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 5.0
 * @precision high
 * @id py/check_icns_dos
 * @tags security
 *       external/cwe/cwe-20
 */

// 导入Python库，用于分析Python代码
import python
// 导入不安全反序列化查询模块，用于检测不安全的反序列化操作
import semmle.python.security.dataflow.UnsafeDeserializationQuery
// 导入路径图类，用于表示数据流路径
import UnsafeDeserializationFlow::PathGraph
// 从路径图中选择源节点和汇节点
from UnsafeDeserializationFlow::PathNode source, UnsafeDeserializationFlow::PathNode sink
// 条件：存在从源节点到汇节点的数据流路径
where UnsafeDeserializationFlow::flowPath(source, sink)
// 选择结果：汇节点、源节点、路径信息以及描述信息
select sink.getNode(), source, sink, "Unsafe deserialization depends on a $@.", source.getNode(),  "user-provided value"