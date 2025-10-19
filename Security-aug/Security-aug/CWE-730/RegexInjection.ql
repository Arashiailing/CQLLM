/**
 * @name Regular expression injection
 * @description User input should not be used in regular expressions without first being escaped,
 *              otherwise a malicious user may be able to inject an expression that could require
 *              exponential time on certain inputs.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.5
 * @precision high
 * @id py/regex-injection
 * @tags security
 *       external/cwe/cwe-730
 *       external/cwe/cwe-400
 */

// 导入Python库
import python
// 私有导入Semmle Python概念库
private import semmle.python.Concepts
// 导入Semmle Python安全数据流中的正则表达式注入查询库
import semmle.python.security.dataflow.RegexInjectionQuery
// 从RegexInjectionFlow中导入路径图类
import RegexInjectionFlow::PathGraph

// 从RegexInjectionFlow中导入源节点和汇节点，以及正则表达式执行实例
from
  RegexInjectionFlow::PathNode source, RegexInjectionFlow::PathNode sink,
  RegexExecution regexExecution
// 条件：如果存在从源节点到汇节点的流动路径，并且汇节点是正则表达式执行的一部分
where
  RegexInjectionFlow::flowPath(source, sink) and
  regexExecution = sink.getNode().(Sink).getRegexExecution()
// 选择汇节点、源节点、汇节点本身，并生成报告信息
select sink.getNode(), source, sink,
  "This regular expression depends on a $@ and is executed by $@.", source.getNode(),
  "user-provided value", regexExecution, regexExecution.getName()
