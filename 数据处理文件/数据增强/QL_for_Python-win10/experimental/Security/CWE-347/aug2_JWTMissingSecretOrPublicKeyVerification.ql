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

// 导入Python分析所需的库，用于代码解析和安全概念分析
import python
import experimental.semmle.python.Concepts

// 查找所有未进行签名验证的JWT解码操作实例
from JwtDecoding insecureJwtOperation
// 筛选条件：JWT解码操作未使用密钥或公钥进行签名验证
where not insecureJwtOperation.verifiesSignature()
// 输出结果：JWT有效载荷及相应的安全问题描述
select insecureJwtOperation.getPayload(), "is not verified with a cryptographic secret or public key."