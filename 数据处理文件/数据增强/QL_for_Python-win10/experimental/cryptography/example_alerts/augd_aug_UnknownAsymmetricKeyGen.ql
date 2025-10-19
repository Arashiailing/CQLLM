/**
 * @name 非对称密钥生成中的不确定密钥大小
 * @description 识别非对称加密算法密钥生成过程中，密钥大小无法在静态分析中确定的情况
 * @id py/unknown-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// 查找非对称密钥生成操作，其中密钥大小无法静态验证
from AsymmetricKeyGen asymmetricKeyGeneration, DataFlow::Node keyConfigSource, string cryptoAlgorithmName
where
  // 获取密钥配置源和算法名称
  keyConfigSource = asymmetricKeyGeneration.getKeyConfigSrc() and
  cryptoAlgorithmName = asymmetricKeyGeneration.getAlgorithm().getName() and
  // 确保密钥生成操作没有静态验证的密钥大小
  not asymmetricKeyGeneration.hasKeySize(keyConfigSource)
select asymmetricKeyGeneration,
  // 报告问题，指出算法和配置源信息
  "用于算法 " + cryptoAlgorithmName.toString() + " 的密钥生成使用了无法静态验证的密钥大小，在配置源 $@", keyConfigSource, keyConfigSource.toString()