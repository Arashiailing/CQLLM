/**
 * @name Weak KDF Modee
 * @description KDF mode, if specified, must be CounterMode
 * @kind problem
 * @id py/kdf-weak-mode
 * @problem.severity error
 * @precision high
 */

// 导入Python库
import python
// 导入实验性加密概念库
import experimental.cryptography.Concepts
// 私有导入实验性加密工具库，并重命名为Utils
private import experimental.cryptography.utils.Utils as Utils

// 从KeyDerivationOperation操作和DataFlow::Node模式配置源中选择数据
from KeyDerivationOperation op, DataFlow::Node modeConfSrc
where
  // 检查操作是否需要模式
  op.requiresMode() and
  // 获取操作的模式源
  modeConfSrc = op.getModeSrc() and
  // 检查模式源是否不是CounterMode
  not modeConfSrc =
    API::moduleImport("cryptography")
        .getMember("hazmat")
        .getMember("primitives")
        .getMember("kdf")
        .getMember("kbkdf")
        .getMember("Mode")
        .getMember("CounterMode")
        .asSource()
// 选择操作、消息、模式配置源及其字符串表示形式
select op, "Key derivation mode is not set to CounterMode. Mode Config: $@", modeConfSrc,
  modeConfSrc.toString()
