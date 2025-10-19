/**
 * @name X.509 certificate verification failure
 * @description Verification of an X.509 certificate fails because the system's root certificates are not available.
 * @kind problem
 * @problem.severity error
 * @precision low
 * @security-severity 9.1
 * @id py/x509_certificate
 * @tags security
 *       external/cwe/cwe-295
 */

// 导入Python库，用于处理Python代码的解析和分析
import python

// 导入X509证书验证失败查询模块
import semmle.python.security.dataflow.X509CertificateVerificationFailureQuery

// 定义查询谓词，查找X.509证书验证失败问题
query predicate problems = X509CertificateVerificationFailure::verificationFailsWithoutSystemRoots();