/**
* @name CWE-20: Improper Input Validation
*
@description The product receives input
    or data, but it does * not validate
    or incorrectly validates that the input has the * properties that are required to process the data safely
    and * correctly.
*
@id py/check_icns_dos
*
@tags security * external/cwe/cwe-20
*
/// 导入Python库，用于分析Python代码
import python
// 导入PolynomialReDoSQuery模块，用于检测多项式复杂度的正则表达式问题
import semmle.python.security.dataflow.PolynomialReDoSQuery
// 导入PathGraph类，用于路径图分析
import PolynomialReDoSFlow::PathGraph
// 从以下数据源中选择数据from
// 定义源节点和汇节点，类型为PathNode PolynomialReDoSFlow::PathNode source, PolynomialReDoSFlow::PathNode sink,
// 定义Sink类型的汇节点 Sink sinkNode,
// 定义一个表示回溯项的正则表达式对象 PolynomialBackTrackingTerm regexpwhere
// 条件：存在从源节点到汇节点的数据流路径 PolynomialReDoSFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Regular expression depends on a $@.", source.getNode(), "user-provided value"