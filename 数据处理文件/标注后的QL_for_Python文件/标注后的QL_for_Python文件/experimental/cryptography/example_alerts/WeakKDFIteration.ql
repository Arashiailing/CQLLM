/**
 * @name Use iteration count at least 100k to prevent brute force attacks
 * @description When deriving cryptographic keys from user-provided inputs such as password,
 * use sufficient iteration count (at least 100k).
 *
 * This query will alert if the iteration count is less than 10000 (i.e., a constant <100000 is observed)
 * or if the source for the iteration count is not known statically.
 * @kind problem
 * @id py/kdf-low-iteration-count
 * @problem.severity error
 * @precision high
 */

// 导入Python库
import python
// 导入实验性加密概念库
import experimental.cryptography.Concepts
// 私有导入实验性加密工具库，并重命名为Utils
private import experimental.cryptography.utils.Utils as Utils

// 从KeyDerivationOperation操作、字符串消息和数据流节点中选择
from KeyDerivationOperation op, string msg, DataFlow::Node iterConfSrc
where
  // 需要迭代的操作
  op.requiresIteration() and
  // 获取迭代大小源
  iterConfSrc = op.getIterationSizeSrc() and
  (
    // 如果存在整数字面量值并且该值小于10000
    exists(iterConfSrc.asExpr().(IntegerLiteral).getValue()) and
    iterConfSrc.asExpr().(IntegerLiteral).getValue() < 10000 and
    msg = "Iteration count is too low. "
    // 或者如果不存在整数字面量值
    or
    not exists(iterConfSrc.asExpr().(IntegerLiteral).getValue()) and
    msg = "Iteration count is not a statically verifiable size. "
  )
select 
  // 选择操作对象、消息、迭代配置表达式及其字符串表示
  op, msg + "Iteration count must be a minimum of 10000. Iteration Config: $@",
  iterConfSrc.asExpr(), iterConfSrc.asExpr().toString()
