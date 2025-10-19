/**
 * @name 未知密钥生成密钥大小
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
from AsymmetricKeyGen keyGen, DataFlow::Node configSrc, string algoName
where
  // 确保密钥生成操作没有静态验证的密钥大小
  not keyGen.hasKeySize(configSrc) and
  // 获取密钥配置源和算法名称
  configSrc = keyGen.getKeyConfigSrc() and
  algoName = keyGen.getAlgorithm().getName()
select keyGen,
  // 报告问题，指出算法和配置源信息
  "用于算法 " + algoName.toString() + " 的密钥生成使用了无法静态验证的密钥大小，在配置源 $@", configSrc, configSrc.toString()