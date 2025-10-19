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

// 定义查询变量：检测密钥派生函数中盐值大小不足的情况
from KeyDerivationOperation keyDerivationFunc, DataFlow::Node saltSizeNode, API::CallNode urandomCall, string alertMessage
where
  // 条件1：确保密钥派生操作需要盐值
  keyDerivationFunc.requiresSalt() and
  
  // 条件2：验证盐值配置源是os.urandom
  urandomCall = keyDerivationFunc.getSaltConfigSrc() and
  urandomCall = API::moduleImport("os").getMember("urandom").getACall() and
  
  // 条件3：追踪盐值大小参数的最终来源
  saltSizeNode = CryptoUtils::getUltimateSrcFromApiNode(urandomCall.getParameter(0, "size")) and
  
  // 条件4：安全检查 - 验证盐值大小是否足够或可静态确定
  (
    // 子情况A：盐值大小无法静态验证（动态确定）
    not exists(saltSizeNode.asExpr().(IntegerLiteral).getValue()) and
    alertMessage = "Salt config is not a statically verifiable size. "
    or
    // 子情况B：盐值大小不足（小于16字节）
    saltSizeNode.asExpr().(IntegerLiteral).getValue() < 16 and
    alertMessage = "Salt config is insufficiently large. "
  )
select keyDerivationFunc,  // 选择存在安全问题的密钥派生操作
  alertMessage + "Salt size must be a minimum of 16 (bytes). os.urandom Config: $@, Size Config: $@",  // 构建安全警报消息
  urandomCall, urandomCall.toString(),  // 显示urandom调用及其字符串表示
  saltSizeNode, saltSizeNode.toString()  // 显示盐值大小参数及其字符串表示