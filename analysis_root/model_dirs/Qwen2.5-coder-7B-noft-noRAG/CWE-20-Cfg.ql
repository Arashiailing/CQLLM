/**
 * @name Unsafe shell command constructed from library input
 * @description Using externally controlled strings in a command line may allow a malicious
 *              user to change the meaning of the command.  * @kind path-problem
 * @problem.severity error * @security-severity 6.3 * @precision medium
 * @id py/shell-command-constructed-from-input * @tags correctness
 *       security *       external/cwe/cwe-078 *       external/cwe/cwe-088
 *       external/cwe/cwe-073
 */

// 导入Python库，用于分析Python代码
import python

// 导入不安全Shell命令构造查询模块
import semmle.python.security.dataflow.UnsafeShellCommandConstructionQuery

// 导入路径图类，用于表示数据流路径
import UnsafeShellCommandConstructionFlow::PathGraph

// 从路径图中选择源节点和汇节点，以及汇节点的详细信息
from
  UnsafeShellCommandConstructionFlow::PathNode source, // 源节点，表示外部输入的起点
  UnsafeShellCommandConstructionFlow::PathNode sink, // 汇节点，表示命令执行的终点
  Sink sinkNode // 汇节点的详细信息

// 使用where子句定义数据流路径的条件，即source到sink的路径
where UnsafeShellCommandConstructionFlow::flowPath(source, sink) and
  sinkNode = sink.getNode()

// 选择结果：汇节点、源节点、路径信息等
select sinkNode, source, sink,
  "Unsafe shell command constructed from $@.", source.getNode(),
  "user-controlled library input"