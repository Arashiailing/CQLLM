/**
 * @name CWE CATEGORY: Permissions, Privileges, and Access Controls
 * @id py/cloud-cwe-264
 */
import python
import semmle.codeql.dataflow.DataFlow
import semmle.python.security.dataflow.SecretDetection

from StringLiteral literal, Node node
where
  // 匹配常见的敏感信息模式（如密码、密钥等）
  (literal.getValue() matches /[a-zA-Z0-9]{8,}/ and not literal.getValue().matches(/^[A-Fa-f0-9]{32,}$/))
  and
  // 检测字符串字面量是否出现在配置项、环境变量或硬编码位置
  (node instanceof ConfigItem or node instanceof EnvVar or node instanceof Literal)
  and
  // 排除非敏感上下文（如日志级别、版本号等）
  not (literal.getValue() matches /(?:INFO|DEBUG|ERROR|WARNING|VERSION|BUILD|RELEASE)/)
select literal, "Detected potential cleartext storage of sensitive data"