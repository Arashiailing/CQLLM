/**
 * @name Command injection
 * @description Constructing a command line from a user-supplied input may allow an attacker to execute arbitrary commands.
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

// 导入Python库，用于分析Python代码
import python

// 导入安全数据流分析库，用于检测命令注入问题
import semmle.python.security.dataflow.CommandInjectionQuery

// 导入命令注入路径图类，用于表示数据流路径
import CommandInjectionFlow::PathGraph

// 从命令注入路径图中选择源节点和汇节点
from CommandInjectionFlow::PathNode source, CommandInjectionFlow::PathNode sink

// 条件：存在从源节点到汇节点的路径
where CommandInjectionFlow::flowPath(source, sink)

// 选择汇节点、源节点、路径信息以及描述信息
select sink.getNode(), source, sink, "This command line depends on a $@.", source.getNode(), "user-provided value"