/**
 * @name CWE-77: Improper Neutralization of Special Elements used in a Command ('Command Injection')
 * @description The product constructs all or part of a command using externally-influenced input from an upstream component, but it does not neutralize or incorrectly neutralizes special elements that could modify the intended command when it is sent to a downstream component.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.8
 * @sub-severity high
 * @precision high
 * @id py/allow_execmod
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
select sink.getNode(), source, sink, "This command line depends on a $@.", source.getNode(),