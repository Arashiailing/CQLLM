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

// 引入Python代码分析的基础库和安全概念模块
import python
import experimental.semmle.python.Concepts

// 识别所有缺乏签名验证机制的JWT解码操作
from JwtDecoding jwtDecodeWithoutVerification
where 
    // 过滤条件：确保JWT解码操作未通过密钥或公钥验证签名
    not jwtDecodeWithoutVerification.verifiesSignature()
select 
    // 结果输出：展示未经验证的JWT有效载荷及安全风险描述
    jwtDecodeWithoutVerification.getPayload(), 
    "is not verified with a cryptographic secret or public key."