/**
 * @name Uncontrolled data used in path expression
 * @description Accessing paths influenced by users can allow an attacker to access unexpected resources.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.5
 * @sub-severity high
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

import python  // 导入Python库，用于分析Python代码
import semmle.python.security.dataflow.PathInjectionQuery  // 导入路径注入查询模块
import PathInjectionFlow::PathGraph  // 导入路径图模块，用于数据流分析

from PathInjectionFlow::PathNode source, PathInjectionFlow::PathNode sink  // 定义数据流源节点和汇节点
where PathInjectionFlow::flowPath(source, sink)  // 条件：存在从源节点到汇节点的数据流路径
select sink.getNode(), source, sink, "This path depends on a $@.", source.getNode(),  "user-provided value"