/**
 * @name CWE-255: Cleartext Storage
 * @id py/cleartext-storage
 */
import python
import semmle.codeql.dataflow.DataFlow
import semmle.python.security.sensitiveData

from Call writeCall, String sensitiveData
where
  // 检测敏感数据（如密码）直接写入文件或数据库
  sensitiveData = "password" or sensitiveData = "secret" or sensitiveData = "token"
  and writeCall.getTarget().getName() = "write"  // 假设写入操作名为write
  and exists(Argument arg | arg.getPos() = 0 and arg.getExpression().getValue().toString() = sensitiveData)
  and not exists(Call encryptCall |
    DataFlow::pathExists(writeCall, encryptCall)  // 检查是否经过加密处理
  )
select writeCall, "Cleartext storage of sensitive data detected."