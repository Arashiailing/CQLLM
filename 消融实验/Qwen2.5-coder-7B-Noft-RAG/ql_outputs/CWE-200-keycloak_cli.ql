/**
* @name CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
*
@description Exposing sensitive information to an unauthorized actor
*
@id py/keycloak_cli
*
@tags security * external/cwe/cwe-200
*/
import python
import semmle.python.security.dataflow.SensitiveInformationExposureQuery
// 导入路径图类，用于表示数据流路径
import SensitiveInformationExposureFlow::PathGraph
// 定义数据流源节点和汇节点的变量source和sink
from SensitiveInformationExposureFlow::PathNode source, SensitiveInformationExposureFlow::PathNode sink
// 使用where子句过滤出存在数据流路径的源节点和汇节点对
    where SensitiveInformationExposureFlow::flowPath(source, sink)
// 选择符合条件的汇节点、源节点和汇节点，并生成相应的结果
    select sink.getNode(), source, sink, "Sensitive information is exposed to an unauthorized actor."