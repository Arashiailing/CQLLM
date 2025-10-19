/**
 * @name Insufficient KDF Salt Size
 * @description Key Derivation Function (KDF) salts must be at least 128 bits (16 bytes) in length.
 *
 * This rule identifies security vulnerabilities where the salt size used in key derivation
 * functions is less than the required 128 bits, or when the salt size cannot be statically
 * determined during code analysis. Insufficient salt size can weaken cryptographic security
 * by making the derived keys more susceptible to brute-force attacks.
 * @kind problem
 * @id py/kdf-small-salt-size
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as CryptoUtils

// 检测密钥派生函数中盐值大小不足的查询
from KeyDerivationOperation keyDerivationFunc, DataFlow::Node saltSizeArg, API::CallNode urandomCall, string alertMessage
where
  // 基本条件：密钥派生函数需要盐值
  keyDerivationFunc.requiresSalt() and
  
  // 盐值配置源条件：确保使用os.urandom作为盐值源
  urandomCall = keyDerivationFunc.getSaltConfigSrc() and
  urandomCall = API::moduleImport("os").getMember("urandom").getACall() and
  
  // 获取盐值大小参数的最终来源
  saltSizeArg = CryptoUtils::getUltimateSrcFromApiNode(urandomCall.getParameter(0, "size")) and
  
  // 安全检查条件：盐值大小不足或无法静态验证
  (
    // 情况1：盐值大小不是静态可验证的（动态确定）
    not exists(saltSizeArg.asExpr().(IntegerLiteral).getValue()) and
    alertMessage = "Salt config is not a statically verifiable size. "
    or
    // 情况2：盐值大小不够大（小于16字节）
    saltSizeArg.asExpr().(IntegerLiteral).getValue() < 16 and
    alertMessage = "Salt config is insufficiently large. "
  )
select keyDerivationFunc,  // 选择存在安全问题的密钥派生函数
  alertMessage + "Salt size must be a minimum of 16 (bytes). os.urandom Config: $@, Size Config: $@",  // 构建安全警报消息
  urandomCall, urandomCall.toString(),  // 显示urandom调用及其字符串表示
  saltSizeArg, saltSizeArg.toString()  // 显示盐值大小参数及其字符串表示