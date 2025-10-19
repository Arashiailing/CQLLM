/**
 * @name Information exposure through an exception
 * @description Leaking information about an exception, such as messages and stack traces, to an
 *              external user can expose implementation details that are useful to an attacker for
 *              developing a subsequent exploit.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 5.4
 * @precision high
 * @id py/stack-trace-exposure
 * @tags security
 *       external/cwe/cwe-209
 *       external/cwe/cwe-497
 */

// 引入Python代码分析所需的基础库
import python

// 引入堆栈跟踪信息泄露相关的数据流分析模块
import semmle.python.security.dataflow.StackTraceExposureQuery

// 引入路径图分析工具类
import StackTraceExposureFlow::PathGraph

// 查询定义：检测可能暴露给外部用户的堆栈跟踪信息流
from StackTraceExposureFlow::PathNode origin, StackTraceExposureFlow::PathNode destination
where StackTraceExposureFlow::flowPath(origin, destination) // 确保存在从源头到目标的数据流路径
select 
  destination.getNode(), // 选择目标节点作为主要结果
  origin, // 包含源节点用于路径显示
  destination, // 包含目标节点用于路径显示
  "$@ flows to this location and may be exposed to an external user.", // 结果描述信息
  origin.getNode(), // 在消息中引用源节点
  "Stack trace information" // 问题类型标识