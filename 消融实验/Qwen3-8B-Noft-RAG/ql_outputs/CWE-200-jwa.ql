/**
 * @name CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
 * @id py/jwa
 */
import python
import semmle.code.cpp.dataflow.DataFlow
import semmle.code.cpp.controlflow.ControlFlow

// 定义敏感信息存储的汇点（例如日志记录、文件写入等）
predicate isSensitiveStorage(Call call) {
  // 示例：检测未加密的日志记录
  call.getTarget().getName() = "info" and
  call.getModule().getName() = "logging"
}

// 定义敏感信息源（例如硬编码密钥、用户输入等）
predicate isSensitiveSource(Expr expr) {
  // 示例：检测硬编码的密钥（需根据实际项目调整）
  expr.getStringLiteral()?.getValue().matches("^[a-fA-F0-9]{32}$")
}

// 数据流分析：从敏感源到存储操作
from Expr sourceExpr, Call storageCall
where isSensitiveSource(sourceExpr) and
      storageCall = getCallFromExpression(sourceExpr) and
      isSensitiveStorage(storageCall)
select storageCall, "Sensitive information stored in cleartext"