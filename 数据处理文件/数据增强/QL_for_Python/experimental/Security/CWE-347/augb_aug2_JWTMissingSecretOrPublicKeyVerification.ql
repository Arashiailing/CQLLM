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

// 引入Python代码分析的基础库及安全概念相关模块
import python
import experimental.semmle.python.Concepts

// 识别所有JWT解码操作中未使用密钥或公钥进行签名验证的情况
from JwtDecoding unverifiedJwtDecode
// 筛选条件：JWT解码操作缺乏密钥或公钥验证机制
where not unverifiedJwtDecode.verifiesSignature()
// 输出未经验证的JWT有效载荷及其安全风险描述
select unverifiedJwtDecode.getPayload(), "is not verified with a cryptographic secret or public key."