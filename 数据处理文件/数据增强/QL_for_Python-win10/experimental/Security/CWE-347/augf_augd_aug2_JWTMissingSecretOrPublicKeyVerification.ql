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

// 导入Python代码分析基础库和安全概念分析模块
import python
import experimental.semmle.python.Concepts

// 查询目标：定位所有未经验证签名的JWT解码操作实例
from JwtDecoding insecureJwtOperation
// 安全过滤条件：排除已使用密钥或公钥进行签名验证的JWT解码操作
where not insecureJwtOperation.verifiesSignature()
// 输出安全漏洞报告：包含JWT有效载荷和相关的安全风险描述
select insecureJwtOperation.getPayload(), 
       "is not verified with a cryptographic secret or public key."