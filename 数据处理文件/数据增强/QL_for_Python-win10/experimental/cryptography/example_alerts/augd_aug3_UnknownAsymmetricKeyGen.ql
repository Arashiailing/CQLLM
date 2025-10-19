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
from AsymmetricKeyGen asymmetricKeyGen, DataFlow::Node configOrigin, string cryptoAlgorithm
where
  // 获取密钥配置源和算法信息
  (
    configOrigin = asymmetricKeyGen.getKeyConfigSrc() and
    cryptoAlgorithm = asymmetricKeyGen.getAlgorithm().getName()
  ) and
  // 验证操作是否缺少静态可验证的密钥大小
  not asymmetricKeyGen.hasKeySize(configOrigin)
select asymmetricKeyGen,
  // 输出包含算法名称和配置源的诊断信息
  "用于算法 " + cryptoAlgorithm.toString() + " 的密钥生成使用了无法静态验证的密钥大小，在配置源 $@", configOrigin, configOrigin.toString()