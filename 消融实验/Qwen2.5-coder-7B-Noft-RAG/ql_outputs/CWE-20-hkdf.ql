/**
* @name CWE-20: Improper Input Validation
*
@description The product receives input
    or data, but it does * not validate
    or incorrectly validates that the input has the * properties that are required to process the data safely
    and * correctly.
*
@id py/hkdf
*
/// 导入Python库，用于分析Python代码
import python
// 导入与输入验证相关的查询模块
import semmle.python.security.dataflow.InputValidationQuery
// 导入路径图类，用于表示数据流路径
import InputValidationFlow::PathGraph
// 从路径图中选择源节点和汇节点
from InputValidationFlow::PathNode source, InputValidationFlow::PathNode sink
// 条件：存在从源节点到汇节点的数据流路径
    where InputValidationFlow::flowPath(source, sink)
// 选择结果：汇节点、源节点、路径信息、描述信息等
    select sink.getNode(), source, sink, "Input validation is missing
    or incorrect f
    or $@.", source.getNode(), "user-supplied input"