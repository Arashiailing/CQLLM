/**
 * @name Unsafe shell command constructed from library input
 * @description Using externally controlled strings in a command line may allow a malicious
 *              user to change the meaning of the command.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 6.3
 * @precision medium
 * @id py/shell-command-constructed-from-input
 * @tags correctness
 *       security
 *       external/cwe/cwe-078
 *       external/cwe/cwe-088
 *       external/cwe/cwe-073
 */

import python
import semmle.python.security.dataflow.UnsafeShellCommandConstructionQuery
import UnsafeShellCommandConstructionFlow::PathGraph

from  UnsafeShellCommandConstructionFlow::PathNode source, 
     UnsafeShellCommandConstructionFlow::PathNode sink,
     string moduleName,
     string functionName
where 
  UnsafeShellCommandConstructionFlow::flowPath(source, sink) and
  (
    // 检查命令构造函数调用
    sink.getNode() = unsafe_command_constructor(moduleName, functionName)
    or
    // 检查命令构造函数调用的属性引用
    exists(API::CallNode constructorCall |
      sink.getNode() = constructorCall.getAFlowNode() and
      unsafe_command_constructor(moduleName, functionName).getAnInferredReturn() =
        constructorCall.getFunc().(Attr::attribute).getObject()
    )
  )
select sink.getNode(), source, sink, "Call to '" + moduleName + "." + functionName + "' constructs a command line from user input."