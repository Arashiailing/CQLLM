/**
* @name CWE-20: Improper Input Validation
*
@description The product receives input
    or data, but it does * not validate
    or incorrectly validates that the input has the * properties that are required to process the data safely
    and * correctly.
*
@id py/affinity_filter
*/
import python
// 导入Python库，用于分析Python代码
import ExternalAPIs
// 导入外部API库，用于识别外部API调用
import StackTraceExposureFlow::PathGraph
// 导入路径图类，用于数据流分析
from ExternalApiUsedWithUntrustedData externalApi, StackTraceExposureFlow::PathNode source, StackTraceExposureFlow::PathNode sink
    where externalApi = externalApiUsedWithUntrustedData()
    and StackTraceExposureFlow::flowPath(source, sink)
    and sink.getNode() = externalApi.getUntrustedDataNode()
    select sink.getNode(), source, sink, "This external API call exposes stack trace information due to improper input validation."