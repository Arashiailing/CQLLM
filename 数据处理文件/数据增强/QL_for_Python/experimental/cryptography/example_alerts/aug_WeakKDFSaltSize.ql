/**
 * @name Insufficient KDF Salt Size
 * @description Key Derivation Function (KDF) salts must be at least 128 bits (16 bytes) in length.
 *
 * This rule triggers when a salt size configuration is less than the required 128 bits,
 * or when the salt size cannot be statically determined at analysis time.
 * @kind problem
 * @id py/kdf-small-salt-size
 * @problem.severity error
 * @precision high
 */

import python // 导入Python语言库
import experimental.cryptography.Concepts // 导入实验性加密概念库
private import experimental.cryptography.utils.Utils as Utils // 私有导入实验性加密工具库，并重命名为Utils

// 定义数据流查询，从KeyDerivationOperation操作、DataFlow::Node盐值大小来源、API::CallNode urandom函数调用和字符串警报消息中选择
from KeyDerivationOperation keyDerivOp, DataFlow::Node saltSizeSource, API::CallNode urandomCall, string alertMessage
where
  keyDerivOp.requiresSalt() and // 过滤条件：操作需要盐值
  urandomCall = keyDerivOp.getSaltConfigSrc() and // 过滤条件：urandom调用是操作的盐配置源
  urandomCall = API::moduleImport("os").getMember("urandom").getACall() and // 过滤条件：调用是os模块的urandom函数
  saltSizeSource = Utils::getUltimateSrcFromApiNode(urandomCall.getParameter(0, "size")) and // 获取调用参数的最终来源
  (
    // 情况1：盐值大小不是静态可验证的
    not exists(saltSizeSource.asExpr().(IntegerLiteral).getValue()) and
    alertMessage = "Salt config is not a statically verifiable size. "
    or
    // 情况2：盐值大小不够大
    saltSizeSource.asExpr().(IntegerLiteral).getValue() < 16 and
    alertMessage = "Salt config is insufficiently large. "
  )
select keyDerivOp, // 选择密钥派生操作
  alertMessage + "Salt size must be a minimum of 16 (bytes). os.urandom Config: $@, Size Config: $@", urandomCall, // 选择警报消息和urandom调用节点，并格式化输出信息
  urandomCall.toString(), saltSizeSource, saltSizeSource.toString() // 选择urandom调用节点的字符串表示和盐值大小来源及其字符串表示