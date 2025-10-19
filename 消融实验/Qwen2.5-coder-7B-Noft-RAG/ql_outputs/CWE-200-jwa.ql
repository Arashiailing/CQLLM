/**
* @name CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
*
@id py/jwa
* @kind problem
* @problem.severity warning
* @precision high
* @security-severity 8.8
*
@tags security * external/cwe/cwe-200
*
/// 导入Python库，用于分析Python代码
import python
// 导入与敏感信息暴露相关的查询模块
import semmle.python.security.dataflow.SensitiveInfoExposureQuery
// 导入路径图类，用于表示数据流路径
import SensitiveInfoExposureFlow::PathGraph
// 定义数据流源节点和汇节点的变量source和sink
from SensitiveInfoExposureFlow::PathNode source, SensitiveInfoExposureFlow::PathNode sink
// 使用where子句过滤出存在数据流路径的源节点和汇节点对
    where SensitiveInfoExposureFlow::flowPath(source, sink)
// 选择符合条件的汇节点、源节点和汇节点，并生成相应的结果
    select sink.getNode(), source, sink, "Sensitive information is exposed to an unauthorized actor."