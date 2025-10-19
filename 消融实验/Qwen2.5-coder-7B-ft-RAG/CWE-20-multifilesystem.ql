/**
 * @name CWE-20: Improper Input Validation
 * @description The product receives input or data, but it does
 *              not validate or incorrectly validates that the input has the
 *              properties that are required to process the data safely and
 *              correctly.
 * @kind path-problem
 * @problem.severity error
 * @precision high
 * @security-severity 7.5
 * @id py/multifilesystem
 * @tags correctness
 *       security
 *       external/cwe/cwe-20
 */

// 导入Python库，用于分析Python代码
import python

// 导入路径注入查询模块，用于检测路径注入问题
import semmle.python.security.dataflow.MultifileSystemQuery

// 从路径注入流中导入路径节点类
import MultifileSystemFlow::PathGraph

// 定义数据流源和汇点
from MultifileSystemFlow::PathNode source, MultifileSystemFlow::PathNode sink

// 条件：如果存在从源节点到汇节点的路径流动
where MultifileSystemFlow::flowPath(source, sink)

// 选择汇点节点、源节点、汇点节点，并生成警告信息
select sink.getNode(), source, sink, "The filesystem operation depends on a $@.", source.getNode(),  "user-supplied value"