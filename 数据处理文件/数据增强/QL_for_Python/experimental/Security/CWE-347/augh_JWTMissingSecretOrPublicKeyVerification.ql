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

// 导入Python分析库和实验性安全概念模块
import python
import experimental.semmle.python.Concepts

// 识别未进行签名验证的JWT解码操作实例
from JwtDecoding jwtDecodeInstance
// 筛选条件：定位那些未执行签名验证的JWT解码操作
where not jwtDecodeInstance.verifiesSignature()
// 输出结果：返回JWT有效载荷并标记安全风险
select jwtDecodeInstance.getPayload(), "is not verified with a cryptographic secret or public key."