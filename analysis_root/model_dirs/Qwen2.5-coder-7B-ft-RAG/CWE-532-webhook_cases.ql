/**
 * @name CWE-532: Insertion of Sensitive Information into Log File
 * @description The product writes sensitive information to a log file.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 6.1
 * @precision high
 * @id py/webhook_cases
 */

// 导入Python库
import python

// 导入日志注入数据流查询模块
import semmle.python.security.dataflow.LogInjectionQuery

// 导入日志注入路径图类
import LogInjectionFlow::PathGraph

// 定义查询，查找从用户输入到日志记录的路径
from LogInjectionFlow::PathNode source, LogInjectionFlow::PathNode sink
where
  // 确保存在从源节点到汇节点的数据流路径
  LogInjectionFlow::flowPath(source, sink)
select
  // 选择日志条目节点、源节点、汇节点、描述信息以及用户输入的值
  sink.getNode(),
  source,
  sink,
  "This log entry depends on a $@.",
  source.getNode(),
  "user-provided value"