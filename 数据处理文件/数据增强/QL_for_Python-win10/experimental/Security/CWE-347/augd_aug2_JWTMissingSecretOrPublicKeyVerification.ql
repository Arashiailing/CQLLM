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

// 定义查询目标：识别所有未经验证的JWT解码操作
from JwtDecoding unverifiedJwtDecode
// 应用安全过滤条件：确保JWT解码操作未使用密钥或公钥进行签名验证
where not unverifiedJwtDecode.verifiesSignature()
// 输出安全漏洞详情：包括JWT有效载荷和相应的安全风险描述
select unverifiedJwtDecode.getPayload(), "is not verified with a cryptographic secret or public key."