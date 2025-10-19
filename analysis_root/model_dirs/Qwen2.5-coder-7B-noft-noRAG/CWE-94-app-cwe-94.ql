/**
 * @name Code injection
 * @description Interpreting unsanitized user input as code allows a malicious user to perform arbitrary
 *              code execution.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.3
 * @sub-severity high
 * @precision high
 * @id py/app-cwe-94
 * @tags security
 *       external/cwe/cwe-094
 *       external/cwe/cwe-095
 *       external/cwe/cwe-116
 */

import python // 导入Python语言库，用于分析Python代码
import semmle.python.security.dataflow.CodeInjectionQuery // 导入CodeInjectionQuery模块，用于检测代码注入漏洞
import CodeInjectionFlow::PathGraph // 导入CodeInjectionFlow模块中的PathGraph类，用于表示数据流路径

// 从CodeInjectionFlow命名空间中导入PathNode类，表示数据流路径的源节点和汇节点
from CodeInjectionFlow::PathNode source, CodeInjectionFlow::PathNode sink
// 检查是否存在从源节点到汇节点的流动路径
where CodeInjectionFlow::flowPath(source, sink)
// 选择结果：汇节点、源节点、路径信息以及描述信息
select sink.getNode(), source, sink, "This code execution depends on a $@.", source.getNode(), "user-provided value"