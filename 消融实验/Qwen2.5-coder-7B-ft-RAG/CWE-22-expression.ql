/**
 * @name Uncontrolled data used in path expression
 * @description Accessing paths influenced by users can allow an attacker to access unexpected resources.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.5
 * @sub-severity high
 * @precision high
 * @id py/expression
 * @tags correctness
 *       security
 *       external/cwe/cwe-022
 *       external/cwe/cwe-023
 *       external/cwe/cwe-036
 *       external/cwe/cwe-073
 *       external/cwe/cwe-099
 */

import python  // 导入Python库，用于分析Python代码
import semmle.python.security.dataflow.PathInjectionQuery  // 导入路径注入查询模块
import PathInjectionFlow::PathGraph  // 导入路径图模块，用于数据流分析

// 从路径图中选择源节点和汇节点
from PathInjectionFlow::PathNode source, PathInjectionFlow::PathNode sink

// 使用where子句定义数据流路径的条件，即source到sink的路径
where PathInjectionFlow::flowPath(source, sink)

// select子句选择要返回的结果，包括sink节点、source节点、路径信息等
select sink.getNode(), source, sink, "This path depends on a $@.", source.getNode(),  "user-provided value"