/**
 * @name 非对称密钥生成中使用未知密钥大小
 * @description 检测在非对称加密密钥生成过程中使用了无法通过静态分析验证的密钥大小的场景。
 *              这种做法可能导致系统采用不安全的密钥长度，从而增加被破解的风险。
 * @id py/unknown-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// 查找所有非对称密钥生成操作，其中密钥大小无法通过静态分析确定
from AsymmetricKeyGen asymmetricKeyGeneration, DataFlow::Node keyConfigurationSource, string cryptographicAlgorithmName
where
  // 获取密钥配置的来源节点和算法名称
  keyConfigurationSource = asymmetricKeyGeneration.getKeyConfigSrc()
  and cryptographicAlgorithmName = asymmetricKeyGeneration.getAlgorithm().getName()
  and
  // 验证密钥生成操作确实没有静态可验证的密钥大小
  not asymmetricKeyGeneration.hasKeySize(keyConfigurationSource)
select asymmetricKeyGeneration,
  // 构建告警消息，指出特定算法的密钥生成使用了无法静态验证的密钥大小
  "算法 " + cryptographicAlgorithmName + " 的密钥生成使用了无法静态验证的密钥大小，配置源位于 $@", keyConfigurationSource, keyConfigurationSource.toString()