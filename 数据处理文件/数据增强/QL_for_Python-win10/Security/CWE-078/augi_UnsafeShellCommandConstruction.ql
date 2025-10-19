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

// 引入Python语言分析支持
import python

// 引入不安全Shell命令构造的数据流分析模块
import semmle.python.security.dataflow.UnsafeShellCommandConstructionQuery

// 引入路径图类，用于表示和可视化数据流路径
import UnsafeShellCommandConstructionFlow::PathGraph

// 查询主体：识别从外部输入到不安全Shell命令的数据流路径
from
  UnsafeShellCommandConstructionFlow::PathNode externalInput, // 表示外部输入的源节点
  UnsafeShellCommandConstructionFlow::PathNode commandSink,   // 表示不安全命令执行的汇节点
  Sink executionDetails                                       // 汇节点的详细信息对象
where
  // 验证存在从外部输入到命令执行点的数据流路径
  UnsafeShellCommandConstructionFlow::flowPath(externalInput, commandSink) and
  // 获取汇节点的具体执行细节
  executionDetails = commandSink.getNode()
select 
  // 输出结果：字符串构造方式、输入源节点、命令执行节点
  executionDetails.getStringConstruction(), externalInput, commandSink,
  // 构造描述信息，解释数据流关系和安全风险
  "This " + executionDetails.describe() + " which depends on $@ is later used in a $@.", 
  externalInput.getNode(), "library input", 
  executionDetails.getCommandExecution(), "shell command"