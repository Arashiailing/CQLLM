/**
 * @name 非对称密钥生成中使用未知密钥大小
 * @description 检测非对称密钥生成操作中使用了无法静态验证的密钥大小
 * @id py/unknown-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// 查询非对称密钥生成操作、密钥配置源节点和加密算法名称
from AsymmetricKeyGen asymmetricKeyGeneration, DataFlow::Node keyConfigurationSource, string cryptoAlgorithmName
where
  // 获取密钥配置源节点
  keyConfigurationSource = asymmetricKeyGeneration.getKeyConfigSrc() and
  // 获取加密算法名称
  cryptoAlgorithmName = asymmetricKeyGeneration.getAlgorithm().getName() and
  // 检查密钥大小是否无法静态确定
  not asymmetricKeyGeneration.hasKeySize(keyConfigurationSource)
select asymmetricKeyGeneration,
  // 输出警告信息，包含加密算法名称和配置源位置
  "用于算法 " + cryptoAlgorithmName.toString() + " 的密钥生成使用了无法静态验证的密钥大小，在配置源 $@", keyConfigurationSource, keyConfigurationSource.toString()