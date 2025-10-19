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

// 引入Python分析库，提供Python代码分析的基础功能
import python

// 引入命令注入安全数据流分析库，支持检测潜在的命令注入漏洞
import semmle.python.security.dataflow.CommandInjectionQuery

// 引入命令注入流路径图模块，用于可视化数据流路径
import CommandInjectionFlow::PathGraph

// 查询起点：从命令注入流图中提取起点(origin)和终点(target)节点
// 筛选条件：确保存在从起点到终点的有效数据流路径
from CommandInjectionFlow::PathNode origin, CommandInjectionFlow::PathNode target
where CommandInjectionFlow::flowPath(origin, target)
// 输出结果：包含目标节点、源节点、完整路径及描述信息
select target.getNode(), origin, target, "This command line depends on a $@.", origin.getNode(),
  // 补充说明：标识该命令行依赖于外部输入的用户提供值
  "user-provided value"