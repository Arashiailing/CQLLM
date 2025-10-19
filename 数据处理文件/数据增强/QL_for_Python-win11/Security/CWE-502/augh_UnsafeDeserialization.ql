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

// 引入Python代码分析支持库
import python

// 引入处理不安全反序列化问题的数据流分析模块
import semmle.python.security.dataflow.UnsafeDeserializationQuery

// 引入用于可视化数据流路径的图形表示工具
import UnsafeDeserializationFlow::PathGraph

// 定义查询范围：从数据流图中识别潜在的不安全反序列化路径
from UnsafeDeserializationFlow::PathNode originPoint, UnsafeDeserializationFlow::PathNode targetPoint
// 筛选条件：确保存在从用户输入源到反序列化目标点的完整数据流
where UnsafeDeserializationFlow::flowPath(originPoint, targetPoint)
// 输出结果：展示目标节点、源节点、目标信息、安全警告描述、源节点信息和用户输入标识
select targetPoint.getNode(), originPoint, targetPoint, "Unsafe deserialization depends on a $@.", originPoint.getNode(),
  "user-provided value"