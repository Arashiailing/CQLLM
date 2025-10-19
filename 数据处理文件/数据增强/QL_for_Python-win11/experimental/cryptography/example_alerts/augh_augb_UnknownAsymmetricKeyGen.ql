/**
 * @name 非对称密钥生成中使用未知密钥大小
 * @description 检测非对称加密算法的密钥生成过程中，使用了无法通过静态分析验证的密钥长度参数
 * @id py/unknown-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// 查询所有非对称密钥生成操作中密钥大小无法静态确定的情况
from AsymmetricKeyGen asymmetricKeyGeneration, DataFlow::Node keyConfigurationSource, string cryptoAlgorithmName
where
  // 获取密钥配置源节点，该节点提供了密钥生成所需的参数
  keyConfigurationSource = asymmetricKeyGeneration.getKeyConfigSrc() and
  // 提取当前使用的加密算法名称
  cryptoAlgorithmName = asymmetricKeyGeneration.getAlgorithm().getName() and
  // 检查密钥大小是否无法在编译时静态确定
  not asymmetricKeyGeneration.hasKeySize(keyConfigurationSource)
select asymmetricKeyGeneration,
  // 构建警告消息，指出具体算法和配置源位置
  "用于算法 " + cryptoAlgorithmName.toString() + " 的密钥生成使用了无法静态验证的密钥大小，在配置源 $@", keyConfigurationSource, keyConfigurationSource.toString()