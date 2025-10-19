/**
 * @name Path traversal and equivalence errors
 * @description Identifies instances where unsafe pathname resolution occurs, which can lead to directory traversal vulnerabilities.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.5
 * @precision high
 * @id py/multifilesystem
 * @tags correctness
 *       security
 *       external/cwe/cwe-22
 *       external/cwe/cwe-23
 *       external/cwe/cwe-36
 *       external/cwe/cwe-73
 *       external/cwe/cwe-99
 */

// 导入Python库，用于分析Python代码
import python

// 导入路径遍历查询模块，用于检测路径遍历漏洞
import PathTraversalAndEquivalenceFlow::PathGraph

// 定义数据流源节点和汇节点的变量source和sink
from PathTraversalAndEquivalenceFlow::PathNode source, PathTraversalAndEquivalenceFlow::PathNode sink

// 使用where子句过滤出存在数据流路径的源节点和汇节点对
where PathTraversalAndEquivalenceFlow::flowPath(source, sink)

// 选择符合条件的汇节点、源节点和汇节点，并生成相应的结果
select sink.getNode(), source, sink, "Insecure pathname resolution involving $@.", source.getNode(),  "untrusted data"