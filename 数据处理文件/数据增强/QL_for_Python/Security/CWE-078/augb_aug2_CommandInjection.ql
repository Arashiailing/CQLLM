/**
 * @name Uncontrolled command line
 * @description Execution of commands with externally controlled strings can enable
 *              attackers to manipulate command behavior, leading to potential system compromise.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.8
 * @sub-severity high
 * @precision high
 * @id py/command-line-injection
 * @tags correctness
 *       security
 *       external/cwe/cwe-078
 *       external/cwe/cwe-088
 */

// 导入Python分析基础库
import python

// 导入命令注入数据流分析模块
import semmle.python.security.dataflow.CommandInjectionQuery

// 导入命令注入流路径可视化模块
import CommandInjectionFlow::PathGraph

// 定义数据流路径分析：从源头节点(source)到汇聚点节点(sink)
from CommandInjectionFlow::PathNode source, CommandInjectionFlow::PathNode sink
// 筛选存在有效数据流路径的节点对
where CommandInjectionFlow::flowPath(source, sink)
// 输出结果：包含汇聚点、源头节点、完整路径及安全描述
select sink.getNode(), source, sink, "This command line depends on a $@.", source.getNode(),
  // 补充说明：标识该命令行依赖外部输入的用户可控值
  "user-provided value"