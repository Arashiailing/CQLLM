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
 */

// 导入Python库，用于分析Python代码
import python

// 导入不安全Shell命令构造查询模块，用于检测命令注入问题
import semmle.python.security.dataflow.UnsafeShellCommandConstructionQuery

// 导入路径图类，用于表示数据流路径
import UnsafeShellCommandConstructionFlow::PathGraph

// 从路径图中选择源节点和汇节点，以及汇节点的详细信息
from  UnsafeShellCommandConstructionFlow::PathNode source, 
       UnsafeShellCommandConstructionFlow::PathNode sink
where UnsafeShellCommandConstructionFlow::flowPath(source, sink) // 条件：存在从源节点到汇节点的流动路径
select sink.getNode(), source, sink, "This command line depends on a $@.", source.getNode(),  // 选择结果：汇节点、源节点、路径信息以及描述信息
  "user-provided value"