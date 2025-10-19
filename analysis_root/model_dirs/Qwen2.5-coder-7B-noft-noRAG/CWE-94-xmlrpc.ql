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
import CodeInjectionFlow::PathGraph // 导入代码注入路径图类

from CodeInjectionFlow::PathNode source, CodeInjectionFlow::PathNode sink // 从代码注入路径图中选择源节点和汇节点
where CodeInjectionFlow::flowPath(source, sink) // 检查是否存在从source到sink的流动路径
select sink.getNode(), source, sink, "This code execution depends on a $@.", source.getNode(), "user-provided value" // 选择结果包括：sink节点、source节点、sink节点、描述信息、source节点、用户输入值的描述