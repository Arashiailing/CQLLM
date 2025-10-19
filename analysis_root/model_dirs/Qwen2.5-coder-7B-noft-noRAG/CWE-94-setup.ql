/**
 * @name Code injection
 * @description Interpreting unsanitized user input as code allows a malicious user to perform arbitrary
 *              code execution.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.3
 * @sub-severity high
 * @precision high
 * @id py/code-injection
 * @tags security
 *       external/cwe/cwe-094
 *       external/cwe/cwe-095
 *       external/cwe/cwe-116
 */

import python // 导入Python语言库，用于分析Python代码
import semmle.python.security.dataflow.CodeInjectionQuery // 导入代码注入查询相关的数据流分析库
import CodeInjectionFlow::PathGraph // 导入代码注入路径图类，用于表示数据流路径

// 定义数据流源节点和汇节点
from CodeInjectionFlow::PathNode source, CodeInjectionFlow::PathNode sink
// 条件：存在从源节点到汇节点的流动路径
where CodeInjectionFlow::flowPath(source, sink)
// 选择结果：汇节点、源节点、路径信息以及描述信息
select sink.getNode(), source, sink, "This code execution depends on a $@.", source.getNode(), "user-provided value"