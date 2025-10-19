/**
 * @name CWE-20: Improper Input Validation
 * @description The product receives input or data, but it does
 *              not validate or incorrectly validates that the input has the
 *              properties that are required to process the data safely and
 *              correctly.
 * @kind path-problem
 * @problem.severity warning
 * @precision high
 * @security-severity 6.1
 * @id py/sslca
 * @tags security
 *       external/cwe/cwe-20
 */

// 导入Python语言支持库
import python

// 导入SSL证书验证模块及其相关路径图类
import sslcertvalidation.SSLCertificateAuthorityCheck
import SSLCertificateAuthorityFlow::PathGraph

// 从路径图中选择源节点和汇节点
from SSLCertificateAuthorityFlow::PathNode source, SSLCertificateAuthorityFlow::PathNode sink

// 条件：存在从源节点到汇节点的数据流路径
where SSLCertificateAuthorityFlow::flowPath(source, sink)

// 选择结果：汇节点、源节点、路径信息、描述信息等
select sink.getNode(), source, sink,
  "$@ provides a certificate authority that cannot be validated.",
  source.getNode(),
  "a trusted root CA certificate"