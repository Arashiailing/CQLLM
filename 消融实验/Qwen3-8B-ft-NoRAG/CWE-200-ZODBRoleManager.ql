import python

/**
 * 检测ZODB RoleManager中明文存储敏感信息的模式
 */
query CWE-200: Exposure of Sensitive Information to an Unauthorized Actor {
  // 查找包含敏感信息的字符串字面量（如密码、密钥等）
  StringLiteral str
  where str.value.matches("password|secret|token|key|cred|pass|auth|token|private|confidential")
    
  // 查找与RoleManager相关的配置方法调用
  Call call
  where call.getCallee().getName() = "setPassword" 
    and call.getArgument(0).isStringLiteral()
    and call.getArgument(0).getLiteral().getValue() = str.value
  
  // 关联字符串字面量和方法调用位置
  select call.getLocation(), "检测到ZODB RoleManager中明文存储敏感信息（密码）"
}