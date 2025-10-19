/**
 * @name Deserialization of user-controlled data
 * @description Deserializing user-controlled data may allow attackers to execute arbitrary code.
 * @kind path-problem
 * @id py/unsafe-deserialization
 * @problem.severity error
 * @security-severity 9.8
 * @sub-severity high
 * @precision high
 * @tags external/cwe/cwe-502
 *       security
 *       serialization
 */

// 导入Python库，用于分析Python代码
import python

// 导入与不安全反序列化相关的查询模块
import semmle.python.security.dataflow.UnsafeDeserializationQuery

// 导入路径图类，用于表示数据流路径
import UnsafeDeserializationFlow::PathGraph

// 从路径图中选择源节点和汇节点
from UnsafeDeserializationFlow::PathNode source, UnsafeDeserializationFlow::PathNode sink

// 条件：存在从源节点到汇节点的数据流路径
where UnsafeDeserializationFlow::flowPath(source, sink)

// 选择结果：汇节点、源节点、汇节点信息、描述信息、源节点信息、用户输入值
select sink.getNode(), source, sink, "Unsafe deserialization depends on a $@.", source.getNode(),  "user-provided value"