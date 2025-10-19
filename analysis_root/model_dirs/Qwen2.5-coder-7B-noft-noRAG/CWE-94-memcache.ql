/**
 * @name Code injection
 * @description Interpreting unsanitized user input as code allows a malicious user to perform arbitrary
 *              code execution.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.3
 * @sub-severity high
 * @precision high
 * @id py/memcache
 * @tags security
 *       external/cwe/cwe-094
 *       external/cwe/cwe-095
 *       external/cwe/cwe-116
 */

import python // 导入Python库，用于分析Python代码
import semmle.python.security.dataflow.CodeInjectionQuery // 导入CodeQL中与代码注入相关的安全数据流查询模块
import CodeInjectionFlow::PathGraph // 从CodeInjectionFlow命名空间中导入PathGraph类，用于表示路径图

// 定义一个查询，查找代码注入的路径问题
from CodeInjectionFlow::PathNode source, CodeInjectionFlow::PathNode sink
where CodeInjectionFlow::flowPath(source, sink) // 条件：存在从源节点到汇节点的流动路径
select sink.getNode(), source, sink, "This code execution depends on a $@.", source.getNode(),  "user-provided value" // 选择结果：汇节点、源节点、路径信息以及描述信息