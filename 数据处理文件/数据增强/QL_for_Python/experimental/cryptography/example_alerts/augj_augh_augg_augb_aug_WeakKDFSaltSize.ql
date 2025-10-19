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

// 检测密钥派生函数中盐值大小不足的安全漏洞
from 
  KeyDerivationOperation keyDerivFunc,  // 密钥派生函数操作
  DataFlow::Node saltSizeNode,         // 盐值大小参数节点
  API::CallNode urandomFuncCall,       // os.urandom函数调用
  string securityAlert                 // 安全警报消息
where
  // 基本条件：确保密钥派生操作需要盐值
  keyDerivFunc.requiresSalt() and
  
  // 验证盐值来源：确认盐值配置是通过os.urandom函数生成的
  urandomFuncCall = keyDerivFunc.getSaltConfigSrc() and
  urandomFuncCall = API::moduleImport("os").getMember("urandom").getACall() and
  
  // 参数追踪：获取盐值大小参数的最终数据源
  saltSizeNode = CryptoUtils::getUltimateSrcFromApiNode(urandomFuncCall.getParameter(0, "size")) and
  
  // 安全评估：检查盐值大小是否满足最低要求或是否可静态确定
  (
    // 情况1：盐值大小无法静态验证（运行时动态确定）
    not exists(saltSizeNode.asExpr().(IntegerLiteral).getValue()) and
    securityAlert = "Salt size cannot be statically verified. "
    or
    // 情况2：盐值大小不足（低于16字节安全阈值）
    saltSizeNode.asExpr().(IntegerLiteral).getValue() < 16 and
    securityAlert = "Salt size is below the minimum required. "
  )
select 
  keyDerivFunc,  // 选择存在安全问题的密钥派生操作
  securityAlert + "Salt size must be a minimum of 16 (bytes). os.urandom Config: $@, Size Config: $@",  // 构建安全警报消息
  urandomFuncCall, urandomFuncCall.toString(),  // 显示urandom调用及其字符串表示
  saltSizeNode, saltSizeNode.toString()  // 显示盐值大小参数及其字符串表示