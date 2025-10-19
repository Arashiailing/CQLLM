/**
 * @name Small KDF salt length.
 * @description KDF salts should be a minimum of 128 bits (16 bytes).
 *
 * This alerts if a constant traces to a salt length sink less than 128-bits or
 * if the value that traces to a salt length sink is not known statically.
 * @kind problem
 * @id py/kdf-small-salt-size
 * @problem.severity error
 * @precision high
 */

import python // 导入Python语言库
import experimental.cryptography.Concepts // 导入实验性加密概念库
private import experimental.cryptography.utils.Utils as Utils // 私有导入实验性加密工具库，并重命名为Utils

// 定义数据流查询，从KeyDerivationOperation操作、DataFlow::Node随机配置源、API::CallNode调用节点和字符串消息中选择
from KeyDerivationOperation op, DataFlow::Node randConfSrc, API::CallNode call, string msg
where
  op.requiresSalt() and // 过滤条件：操作需要盐值
  API::moduleImport("os").getMember("urandom").getACall() = call and // 过滤条件：调用是os模块的urandom函数
  call = op.getSaltConfigSrc() and // 过滤条件：调用是操作的盐配置源
  randConfSrc = Utils::getUltimateSrcFromApiNode(call.getParameter(0, "size")) and // 获取调用参数的最终来源
  (
    not exists(randConfSrc.asExpr().(IntegerLiteral).getValue()) and // 如果最终来源不是静态可验证的大小
    msg = "Salt config is not a statically verifiable size. " // 设置消息为“盐配置不是静态可验证的大小”
    or
    randConfSrc.asExpr().(IntegerLiteral).getValue() < 16 and // 或者如果最终来源的值小于16
    msg = "Salt config is insufficiently large. " // 设置消息为“盐配置不够大”
  )
select op, // 选择操作
  msg + "Salt size must be a minimum of 16 (bytes). os.urandom Config: $@, Size Config: $@", call, // 选择消息和调用节点，并格式化输出信息
  call.toString(), randConfSrc, randConfSrc.toString() // 选择调用节点的字符串表示和最终来源及其字符串表示
