/**
 * @name 非对称加密密钥大小静态分析不可确认
 * @description 识别非对称密钥生成过程中，密钥长度参数无法通过静态分析确定的代码实例
 * @id py/unknown-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// 查找所有非对称密钥生成操作及其密钥大小配置源
from AsymmetricKeyGen asymmetricKeyOp, DataFlow::Node keySizeSource
where
  // 确认配置源与密钥生成操作的关联
  keySizeSource = asymmetricKeyOp.getKeyConfigSrc()
  // 检查密钥大小是否无法静态验证
  and not asymmetricKeyOp.hasKeySize(keySizeSource)
select asymmetricKeyOp,
  // 构建包含算法信息和配置源位置的诊断消息
  "算法 " + asymmetricKeyOp.getAlgorithm().getName() + " 的密钥生成过程中使用了无法静态验证的密钥长度，配置源自 $@", keySizeSource, keySizeSource.toString()