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

// 导入Python分析库和实验性概念模型，提供JWT分析所需的基础类和谓词
import python
import experimental.semmle.python.Concepts

// 查找所有未经验证签名的JWT解码操作
// 这类操作可能导致安全漏洞，因为未验证的JWT可能被篡改
from JwtDecoding insecureJwtDecoding

// 筛选条件：仅选择那些未执行签名验证的JWT解码实例
// verifiesSignature()方法检查JWT解码操作是否验证了签名
where not insecureJwtDecoding.verifiesSignature()

// 输出结果：JWT有效载荷及相应的安全警告信息
// getPayload()方法获取JWT的有效载荷部分
select insecureJwtDecoding.getPayload(), "is not verified with a cryptographic secret or public key."