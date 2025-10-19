/**
 * @name Command execution on a secondary remote server
 * @description user provided command can lead to execute code on an external server that can belong to other users or admins
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.3
 * @precision high
 * @id py/paramiko-command-injection
 * @tags security
 *       experimental
 *       external/cwe/cwe-074
 */

// 导入Python语言库
import python
// 导入实验性的远程命令执行安全分析模块
import experimental.semmle.python.security.RemoteCommandExecution
// 从远程命令执行流中导入路径图类
import RemoteCommandExecutionFlow::PathGraph

// 定义数据流源节点和汇节点
from RemoteCommandExecutionFlow::PathNode source, RemoteCommandExecutionFlow::PathNode sink
// 条件：存在从源节点到汇节点的流路径
where RemoteCommandExecutionFlow::flowPath(source, sink)
// 选择汇节点、源节点、汇节点信息，并生成警告信息
select sink.getNode(), source, sink, "This code execution depends on a $@.", source.getNode(),
  "a user-provided value"
