/**
 * @name CWE-254:CodeInjectionQuery漏洞检测
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

// 导入Python语言分析库
import python

// 导入用于检测代码注入的安全数据流分析模块
import semmle.python.security.dataflow.CodeInjectionQuery

// 导入表示代码注入数据流路径的图结构类
import CodeInjectionFlow::PathGraph

// 从数据流路径图中定义源节点和汇节点变量
from CodeInjectionFlow::PathNode source, CodeInjectionFlow::PathNode sink

// 条件：验证存在从源节点到汇节点的数据流路径
where CodeInjectionFlow::flowPath(source, sink)

// 结果选择：汇节点、源节点、路径信息及描述信息
select sink.getNode(), source, sink, "This code execution depends on a $@.", source.getNode(),  "user-provided value"