/**
 * @name 非对称加密密钥大小不可静态验证
 * @description 检测非对称加密算法密钥生成过程中，密钥大小参数无法通过静态分析确定的代码模式
 * @id py/unknown-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// 查找非对称密钥生成操作及其配置源
from AsymmetricKeyGen asymmetricKeyGeneration, DataFlow::Node keyConfigSource
where
  // 确定密钥配置源
  keyConfigSource = asymmetricKeyGeneration.getKeyConfigSrc()
  and
  // 检查密钥大小是否无法静态验证
  not asymmetricKeyGeneration.hasKeySize(keyConfigSource)
select asymmetricKeyGeneration,
  // 构建包含算法名称和配置源的诊断信息
  "算法 " + asymmetricKeyGeneration.getAlgorithm().getName() + " 的密钥生成使用了无法静态验证的密钥大小，配置源位于 $@", keyConfigSource, keyConfigSource.toString()