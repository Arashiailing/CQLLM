/**
 * @name CWE-59: Improper Link Resolution Before File Access ('Link Following')
 * @description Detection of path injection vulnerabilities
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.5
 * @precision high
 * @id py/path-injection
 * @tags correctness
 *       security
 *       external/cwe/cwe-022
 *       external/cwe/cwe-023
 *       external/cwe/cwe-036
 *       external/cwe/cwe-073
 *       external/cwe/cwe-099
 */

// 导入Python语言支持库
import python

// 导入路径注入分析模块
import semmle.python.security.dataflow.PathInjectionQuery

// 定义路径图类
import PathInjectionFlow::PathGraph

// 定义数据流源和汇点
from PathInjectionFlow::PathNode source, PathInjectionFlow::PathNode sink

// 条件：存在从源到汇的数据流路径
where PathInjectionFlow::flowPath(source, sink)

// 选择结果：汇节点、源节点、汇节点、描述信息
select sink.getNode(), source, sink,
  "This path depends on a $@.",
  source.getNode(),
  "user-provided value"