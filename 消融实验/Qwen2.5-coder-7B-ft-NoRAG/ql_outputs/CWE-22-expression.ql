/**
 * @name Uncontrolled data used in path expression
 * @description Accessing paths influenced by users can allow an attacker to access unexpected resources.
 * @id py/expression
 */

import python  // 导入Python库，用于分析Python代码
import semmle.python.security.dataflow.PathInjectionQuery  // 导入路径注入查询模块
import PathInjectionFlow::PathGraph  // 导入路径图模块，用于数据流分析

from PathInjectionFlow::PathNode source, PathInjectionFlow::PathNode sink  // 从路径图中选择源节点和汇节点
where PathInjectionFlow::flowPath(source, sink)  // 条件：存在从源节点到汇节点的数据流路径
select sink.getNode(), source, sink, "This path depends on a $@.", source.getNode(),  "user-provided value"