/**
* @name CWE-20: Improper Input Validation
*
@id py/sslca
* @kind path-problem
* @problem.severity warning
* @precision high
* @security-severity 5.0
*
@tags security * external/cwe/cwe-20
*
/// 导入Python库，用于分析Python代码
import python
// 导入与SSL证书验证相关的查询模块
import semmle.python.security.dataflow.SSLCertificateValidationQuery
// 导入路径图类，用于表示数据流路径
import SSLCertificateValidationFlow::PathGraph
// 从路径图中选择源节点和汇节点
from SSLCertificateValidationFlow::PathNode source, SSLCertificateValidationFlow::PathNode sink
// 条件：存在从源节点到汇节点的数据流路径
    where SSLCertificateValidationFlow::flowPath(source, sink)
// 选择结果：汇节点、源节点、路径信息、描述信息等
    select sink.getNode(), source, sink, "SSL certificate validation depends on a $@.", source.getNode(), "user-supplied input"