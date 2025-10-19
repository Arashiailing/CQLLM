/**
 * @name CWE-77: Improper Neutralization of Special Elements used in a Command ('Command Injection')
 * @description The product constructs all or part of a command using externally-influenced input from an upstream component,
 *              but it does not neutralize or incorrectly neutralizes special elements that could modify the intended command
 *              when it is sent to a downstream component.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 6.3
 * @precision medium
 * @id py/sealert
 * @tags correctness
 *       security
 *       external/cwe/cwe-078
 *       external/cwe/cwe-088
 *       external/cwe/cwe-073
 */

import python
import semmle.python.security.dataflow.UnsafeShellCommandConstructionQuery
import UnsafeShellCommandConstructionFlow::PathGraph
from  UnsafeShellCommandConstructionFlow::PathNode source, // 源节点，表示外部输入的起点
     UnsafeShellCommandConstructionFlow::PathNode sink,   // 汇节点，表示不安全的命令执行点
     Sink sinkNode                                       // 汇节点的详细信息
where  // 条件：存在从源节点到汇节点的数据流路径
  UnsafeShellCommandConstructionFlow::flowPath(source, sink) and  // 条件：获取汇节点的具体信息
  sinkNode = sink.getNode()
select   // 选择要显示的信息：字符串构造、源节点、汇节点
  sinkNode.getStringConstruction(), source, sink,  // 描述信息：说明该汇节点依赖于某个源节点，并被用于不安全的Shell命令中
  "This " + sinkNode.describe() + " which depends on $@ is later used in a $@.",
  source.getNode(),  "library input",
  sinkNode.getCommandExecution(), "shell command"