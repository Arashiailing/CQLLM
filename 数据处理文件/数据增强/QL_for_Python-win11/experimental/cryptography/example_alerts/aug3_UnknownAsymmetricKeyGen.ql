/**
 * @name 未知密钥生成密钥大小
 * @description 检测非对称密钥生成操作中无法静态验证密钥大小的配置
 * @id py/unknown-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// 查询非对称密钥生成操作及其配置源和算法名称
from AsymmetricKeyGen keyGenerationOp, DataFlow::Node configurationSource, string algorithmName
where
  // 获取密钥配置源
  configurationSource = keyGenerationOp.getKeyConfigSrc() and
  // 获取算法名称
  algorithmName = keyGenerationOp.getAlgorithm().getName() and
  // 验证操作是否缺少静态可验证的密钥大小
  not keyGenerationOp.hasKeySize(configurationSource)
select keyGenerationOp,
  // 输出包含算法名称和配置源的诊断信息
  "用于算法 " + algorithmName.toString() + " 的密钥生成使用了无法静态验证的密钥大小，在配置源 $@", configurationSource, configurationSource.toString()