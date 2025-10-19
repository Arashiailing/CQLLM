/**
 * @name Use iteration count at least 100k to prevent brute force attacks
 * @description When deriving cryptographic keys from user-provided inputs such as password,
 * use sufficient iteration count (at least 100k).
 *
 * This query identifies two risk scenarios:
 * 1. When iteration count is explicitly set below 10000 (static constant)
 * 2. When iteration count source cannot be statically verified
 * @kind problem
 * @id py/kdf-low-iteration-count
 * @problem.severity error
 * @precision high
 */

// 导入Python核心库
import python
// 导入实验性加密概念库
import experimental.cryptography.Concepts
// 导入实验性加密工具库并重命名为CryptoUtils
private import experimental.cryptography.utils.Utils as CryptoUtils

// 从密钥派生操作、警告消息和迭代计数源节点中选择
from KeyDerivationOperation keyDerivationOp, string alertMessage, DataFlow::Node iterationCountSource
where
  // 仅处理需要迭代的密钥派生操作
  keyDerivationOp.requiresIteration() and
  // 获取迭代次数的配置源
  iterationCountSource = keyDerivationOp.getIterationSizeSrc() and
  (
    // 情况1：检测显式设置的低迭代次数（<10000）
    exists(iterationCountSource.asExpr().(IntegerLiteral).getValue()) and
    iterationCountSource.asExpr().(IntegerLiteral).getValue() < 10000 and
    alertMessage = "Iteration count is too low. "
    or
    // 情况2：检测无法静态验证的迭代次数源
    not exists(iterationCountSource.asExpr().(IntegerLiteral).getValue()) and
    alertMessage = "Iteration count is not a statically verifiable size. "
  )
select 
  // 输出操作对象、完整警告消息、迭代配置表达式及其字符串表示
  keyDerivationOp, alertMessage + "Iteration count must be a minimum of 10000. Iteration Config: $@",
  iterationCountSource.asExpr(), iterationCountSource.asExpr().toString()