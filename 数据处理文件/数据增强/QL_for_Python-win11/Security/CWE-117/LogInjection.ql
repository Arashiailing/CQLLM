/**
 * @name Log Injection
 * @description Building log entries from user-controlled data is vulnerable to
 *              insertion of forged log entries by a malicious user.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.8
 * @precision medium
 * @id py/log-injection
 * @tags security
 *       external/cwe/cwe-117
 */

// 导入Python库，用于处理Python代码的解析和分析
import python

// 导入与日志注入相关的安全数据流查询模块
import semmle.python.security.dataflow.LogInjectionQuery

// 从日志注入数据流模块中导入路径图类
import LogInjectionFlow::PathGraph

// 定义一个查询，查找日志注入的潜在路径
from LogInjectionFlow::PathNode source, LogInjectionFlow::PathNode sink
where LogInjectionFlow::flowPath(source, sink) // 条件：存在从源到汇的数据流路径
select sink.getNode(), source, sink, "This log entry depends on a $@.", source.getNode(),
  "user-provided value" // 选择结果包括：日志条目节点、源节点、汇节点、描述信息以及用户输入的值
