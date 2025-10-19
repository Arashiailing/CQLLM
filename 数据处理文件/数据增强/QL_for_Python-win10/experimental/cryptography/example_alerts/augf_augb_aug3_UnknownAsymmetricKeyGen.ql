/**
 * @name 非对称加密密钥尺寸不可静态验证
 * @description 检测在非对称密钥生成场景中，密钥长度参数无法通过静态代码分析确认的实例
 * @id py/unknown-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// 定义非对称密钥生成操作及其配置源
from AsymmetricKeyGen asymmetricKeyGeneration, DataFlow::Node keyConfigOrigin
where
  // 确认配置源与密钥生成操作的关联
  keyConfigOrigin = asymmetricKeyGeneration.getKeyConfigSrc()
  // 检查密钥大小是否无法静态验证
  and not asymmetricKeyGeneration.hasKeySize(keyConfigOrigin)
select asymmetricKeyGeneration,
  // 构建包含算法信息和配置源位置的诊断消息
  "算法 " + asymmetricKeyGeneration.getAlgorithm().getName() + " 的密钥生成过程中使用了无法静态验证的密钥长度，配置源自 $@", keyConfigOrigin, keyConfigOrigin.toString()