/**
 * @name 非对称密钥生成中的未知密钥大小
 * @description 检测非对称密钥生成操作中使用了无法静态验证的密钥大小的情况
 * @id py/unknown-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// 查找非对称密钥生成操作，其中密钥大小无法静态验证
from AsymmetricKeyGen asymmetricKeyGen, DataFlow::Node configSource, string algoName
where
  // 获取密钥配置源和算法名称
  configSource = asymmetricKeyGen.getKeyConfigSrc() and
  algoName = asymmetricKeyGen.getAlgorithm().getName() and
  // 确保密钥生成操作没有静态验证的密钥大小
  not asymmetricKeyGen.hasKeySize(configSource)
select asymmetricKeyGen,
  // 报告问题，指出算法和配置源信息
  "用于算法 " + algoName.toString() + " 的密钥生成使用了无法静态验证的密钥大小，在配置源 $@", configSource, configSource.toString()