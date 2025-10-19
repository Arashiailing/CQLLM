/**
 * @name 非对称密钥生成中的未知密钥大小
 * @description 检测非对称密钥生成操作中无法静态确定密钥尺寸的场景
 * @id py/unknown-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// 查找非对称密钥生成操作及其配置源
from AsymmetricKeyGen asymmetricKeyGeneration, DataFlow::Node keyConfigurationSource, string cryptoAlgorithmName
where
  // 获取密钥配置源节点
  keyConfigurationSource = asymmetricKeyGeneration.getKeyConfigSrc() and
  // 提取加密算法名称
  cryptoAlgorithmName = asymmetricKeyGeneration.getAlgorithm().getName() and
  // 验证密钥生成操作缺少静态可验证的密钥尺寸
  not asymmetricKeyGeneration.hasKeySize(keyConfigurationSource)
select asymmetricKeyGeneration,
  // 构造告警消息，包含算法类型和配置源信息
  "算法 " + cryptoAlgorithmName.toString() + 
  " 的密钥生成使用了无法静态验证的密钥大小，配置源自 $@", 
  keyConfigurationSource, 
  keyConfigurationSource.toString()