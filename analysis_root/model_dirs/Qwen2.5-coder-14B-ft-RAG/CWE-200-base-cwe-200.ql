/**
 * @name CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
 * @description nan
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.5
 * @precision medium
 * @id py/base-cwe-200
 * @tags security
 */

import python
import semmle.python.Concepts
import CleartextLoggingQuery::PathGraph

from
  CleartextLoggingFlow::PathNode source, CleartextLoggingFlow::PathNode sink,
  string messageSuffix, string kind
where
  // 验证数据流路径存在性
  CleartextLoggingFlow::flowPath(source, sink)
  and
  // 从源节点提取敏感信息类型和描述后缀
  (
    kind = "password" and
    messageSuffix = "password"
    or
    kind!= "password" and
    messageSuffix = "sensitive data" and
    // 检查非密码信息的其他类型
    exists(SourceConcept infoSource |
      infoSource = source.getNode() and
      kind = infoSource.getClassification()
    )
  )
select
  // 输出结果包含目标节点、完整路径及详细描述信息
  sink.getNode(), source, sink,
  "$@ is logged in clear text, which exposes it to unauthorized users.",
  source.getNode(), "Clear text log entry", messageSuffix