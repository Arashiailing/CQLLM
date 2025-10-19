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

// 查询变量：识别密钥派生函数中盐值大小不足的安全问题
from KeyDerivationOperation kdfOperation, DataFlow::Node saltSizeParam, API::CallNode urandomInvocation, string diagnosticMessage
where
  // 基本条件：密钥派生操作需要盐值
  kdfOperation.requiresSalt() and
  
  // 盐值来源验证：确保盐值配置来自os.urandom函数
  urandomInvocation = kdfOperation.getSaltConfigSrc() and
  urandomInvocation = API::moduleImport("os").getMember("urandom").getACall() and
  
  // 参数追踪：获取盐值大小参数的最终数据源
  saltSizeParam = CryptoUtils::getUltimateSrcFromApiNode(urandomInvocation.getParameter(0, "size")) and
  
  // 安全评估：检查盐值大小是否满足最低要求或是否可静态确定
  (
    // 情况1：盐值大小无法静态验证（运行时动态确定）
    not exists(saltSizeParam.asExpr().(IntegerLiteral).getValue()) and
    diagnosticMessage = "Salt size cannot be statically verified. "
    or
    // 情况2：盐值大小不足（低于16字节安全阈值）
    saltSizeParam.asExpr().(IntegerLiteral).getValue() < 16 and
    diagnosticMessage = "Salt size is below the minimum required. "
  )
select kdfOperation,  // 选择存在安全问题的密钥派生操作
  diagnosticMessage + "Salt size must be a minimum of 16 (bytes). os.urandom Config: $@, Size Config: $@",  // 构建安全警报消息
  urandomInvocation, urandomInvocation.toString(),  // 显示urandom调用及其字符串表示
  saltSizeParam, saltSizeParam.toString()  // 显示盐值大小参数及其字符串表示