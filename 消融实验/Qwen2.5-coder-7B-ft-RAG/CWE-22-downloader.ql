/**
 * @name Uncontrolled data used in path expression
 * @description Accessing paths influenced by users can allow an attacker to access unexpected resources.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.5
 * @sub-severity high
 * @precision high
 * @id py/downloader
 * @tags correctness
 *       security
 *       external/cwe/cwe-022
 *       external/cwe/cwe-023
 *       external/cwe/cwe-036
 *       external/cwe/cwe-073
 *       external/cwe/cwe-099
 */

import python  // 导入python模块，用于分析Python代码
import semmle.python.security.dataflow.PathInjectionQuery  // 导入PathInjectionQuery模块，用于检测路径注入问题
import PathInjectionFlow::PathGraph  // 导入PathInjectionFlow路径图类，用于表示数据流路径

// 定义数据流源和汇点
from PathInjectionFlow::PathNode source, PathInjectionFlow::PathNode sink

// 条件：如果存在从源到汇点的路径流动
where PathInjectionFlow::flowPath(source, sink)

// 选择汇点节点、源节点、汇点节点，并生成警告信息
select sink.getNode(), source, sink, "This path depends on a $@.", source.getNode(),  "user-provided value"