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

// 导入Python代码分析所需的基础库和安全概念模块
import python
import experimental.semmle.python.Concepts

// 查找所有未进行签名验证的JWT解码操作
from JwtDecoding insecureJwtDecoding
// 筛选条件：JWT解码操作未使用密钥或公钥验证签名
where not insecureJwtDecoding.verifiesSignature()
// 输出结果：未经验证的JWT有效载荷及安全风险描述
select insecureJwtDecoding.getPayload(), "is not verified with a cryptographic secret or public key."