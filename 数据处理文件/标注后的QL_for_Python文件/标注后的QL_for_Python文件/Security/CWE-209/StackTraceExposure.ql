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

// 导入Python库，用于分析Python代码
import python

// 导入自定义的StackTraceExposureQuery模块，用于数据流分析
import semmle.python.security.dataflow.StackTraceExposureQuery

// 从StackTraceExposureFlow命名空间中导入PathGraph类
import StackTraceExposureFlow::PathGraph

// 定义查询，查找可能暴露给外部用户的堆栈跟踪信息路径
from StackTraceExposureFlow::PathNode source, StackTraceExposureFlow::PathNode sink
where StackTraceExposureFlow::flowPath(source, sink) // 条件：存在从源节点到汇节点的路径
select sink.getNode(), source, sink, // 选择汇节点、源节点和汇节点
  "$@ flows to this location and may be exposed to an external user.", source.getNode(), // 注释：信息流向此位置并可能暴露给外部用户
  "Stack trace information" // 注释：堆栈跟踪信息
