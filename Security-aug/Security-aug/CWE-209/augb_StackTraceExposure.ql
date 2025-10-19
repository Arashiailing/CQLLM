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
 *       external/cwe/cwe-497 */

// 导入Python代码分析库
import python

// 导入自定义的堆栈跟踪暴露查询模块，用于数据流分析
import semmle.python.security.dataflow.StackTraceExposureQuery

// 从StackTraceExposureFlow命名空间导入路径图类
import StackTraceExposureFlow::PathGraph

// 定义查询：检测可能暴露给外部用户的堆栈跟踪信息流路径
from StackTraceExposureFlow::PathNode origin, StackTraceExposureFlow::PathNode endpoint
where StackTraceExposureFlow::flowPath(origin, endpoint)
select endpoint.getNode(), origin, endpoint,
  "$@ flows to this location and may be exposed to an external user.", origin.getNode(),
  "Stack trace information"