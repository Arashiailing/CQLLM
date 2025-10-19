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

// 基础 Python 代码分析库
import python

// 不安全反序列化数据流分析模块
import semmle.python.security.dataflow.UnsafeDeserializationQuery

// 数据流路径图表示模块
import UnsafeDeserializationFlow::PathGraph

// 查询起点：用户输入源节点和反序列化汇节点
from UnsafeDeserializationFlow::PathNode userInputSource, UnsafeDeserializationFlow::PathNode deserializationSink
// 筛选条件：存在从用户输入到反序列化点的数据流路径
where UnsafeDeserializationFlow::flowPath(userInputSource, deserializationSink)
// 输出结果：反序列化点节点、输入源节点、反序列化点信息、消息模板、输入源节点、输入源描述
select deserializationSink.getNode(), 
       userInputSource, 
       deserializationSink, 
       "Unsafe deserialization depends on a $@.", 
       userInputSource.getNode(),
       "user-provided value"