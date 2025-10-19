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

// 导入必要的Python分析库和概念模型
import python
import experimental.semmle.python.Concepts

// 查找所有未经验证签名的JWT解码操作
from JwtDecoding unverifiedJwtDecode
// 筛选条件：仅选择那些未执行签名验证的JWT解码实例
where not unverifiedJwtDecode.verifiesSignature()
// 输出结果：JWT有效载荷及相应的安全警告信息
select unverifiedJwtDecode.getPayload(), "is not verified with a cryptographic secret or public key."