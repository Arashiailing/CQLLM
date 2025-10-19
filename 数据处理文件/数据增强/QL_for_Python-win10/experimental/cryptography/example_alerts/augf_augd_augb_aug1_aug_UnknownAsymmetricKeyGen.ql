/**
 * @name 非对称密钥生成中的未知密钥大小
 * @description 识别非对称加密算法在密钥生成过程中，密钥长度无法通过静态分析确定的安全隐患
 * @id py/unknown-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// 查找所有非对称密钥生成操作，其中密钥大小无法在静态分析阶段确定
from AsymmetricKeyGen asymmetricKeyGeneration, DataFlow::Node keyConfigurationSource, string encryptionAlgorithm
where
  // 获取密钥配置的来源节点，用于追踪密钥参数的输入位置
  keyConfigurationSource = asymmetricKeyGeneration.getKeyConfigSrc() and
  // 提取当前密钥生成操作所使用的加密算法名称
  encryptionAlgorithm = asymmetricKeyGeneration.getAlgorithm().getName() and
  // 验证密钥生成操作是否缺少静态可验证的密钥大小参数
  not asymmetricKeyGeneration.hasKeySize(keyConfigurationSource)
select asymmetricKeyGeneration,
  // 生成安全警告信息，指出使用的算法和不可验证的密钥配置源
  "算法 " + encryptionAlgorithm.toString() + " 的密钥生成过程使用了无法静态验证的密钥大小，配置源位于 $@", keyConfigurationSource, keyConfigurationSource.toString()