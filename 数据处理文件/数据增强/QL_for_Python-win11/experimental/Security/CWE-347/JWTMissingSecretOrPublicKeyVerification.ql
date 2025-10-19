/**
 * @name JWT missing secret or public key verification
 * @description The application does not verify the JWT payload with a cryptographic secret or public key.
 * @kind problem
 * @problem.severity warning
 * @id py/jwt-missing-verification
 * @tags security
 *       experimental
 *       external/cwe/cwe-347
 */

// 导入Python库，用于处理Python代码的解析和分析
import python
import experimental.semmle.python.Concepts

// 从JWT解码的概念中获取数据流信息
from JwtDecoding jwtDecoding
// 过滤条件：选择那些没有验证签名的JWT解码实例
where not jwtDecoding.verifiesSignature()
// 选择JWT的有效载荷，并附加问题描述
select jwtDecoding.getPayload(), "is not verified with a cryptographic secret or public key."
