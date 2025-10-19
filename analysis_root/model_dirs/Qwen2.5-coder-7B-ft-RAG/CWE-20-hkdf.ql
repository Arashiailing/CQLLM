/**
 * @name CWE-20: Improper Input Validation
 * @description The product receives input or data, but it does
 *              not validate or incorrectly validates that the input has the
 *              properties that are required to process the data safely and
 *              correctly.
 * @kind path-problem
 * @problem.severity warning
 * @precision high
 * @security-severity 5.0
 * @id py/hkdf
 * @tags security
 *       external/cwe/cwe-20
 */

// 导入Python库，用于分析Python代码
import python

// 导入与HMAC-based Key Derivation Function (HKDF)相关的查询模块
import semmle.python.security.dataflow.HKDFExtractionQuery

// 导入路径图类，用于表示数据流路径
import HKDFExtractionFlow::PathGraph

// 从路径图中选择源节点和汇节点
from HKDFExtractionFlow::PathNode source, HKDFExtractionFlow::PathNode sink

// 条件：存在从源节点到汇节点的数据流路径
where HKDFExtractionFlow::flowPath(source, sink)

// 选择结果：汇节点、源节点、路径信息、描述信息等
select sink.getNode(), source, sink, "Key derivation function output depends on a $@.", source.getNode(),  
  "user-supplied value"