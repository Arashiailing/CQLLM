/**
* @name CWE-20: Improper Input Validation
*
@description The product receives input
    or data, but it does not validate
    or incorrectly validates that the input has the properties that are required to process the data safely
    and correctly.
*
@id py/return_data
*/
import python
// 导入Python库，用于分析Python代码
import semmle.python.security.dataflow.ReturnDataQuery
// 导入返回数据相关的查询模块
import ReturnDataFlow::PathGraph
// 导入路径图类，用于表示数据流路径
from ReturnDataFlow::PathNode source, ReturnDataFlow::PathNode sink
    where ReturnDataFlow::flowPath(source, sink)
// 条件：存在从源节点到汇节点的数据流路径
    select sink.getNode(), source, sink, "Data returned
from a $@.", source.getNode(), "user-provided value"