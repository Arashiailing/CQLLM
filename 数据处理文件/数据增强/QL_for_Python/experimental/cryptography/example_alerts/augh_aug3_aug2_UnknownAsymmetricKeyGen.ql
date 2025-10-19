/**
 * @name 非对称密钥生成中使用未知密钥大小
 * @description 检测非对称密钥生成过程中使用了无法静态验证的密钥大小的情况。
 *              这种情况可能导致密钥强度不足，从而影响加密安全性。
 * @id py/unknown-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// 查询所有非对称密钥生成操作，其中密钥大小无法静态验证
from AsymmetricKeyGen keyGeneration, DataFlow::Node keyConfiguration, string algorithmName
where
  // 获取密钥配置的来源节点
  keyConfiguration = keyGeneration.getKeyConfigSrc() and
  // 获取使用的加密算法名称
  algorithmName = keyGeneration.getAlgorithm().getName() and
  // 确认密钥生成操作没有静态验证的密钥大小
  not keyGeneration.hasKeySize(keyConfiguration)
select keyGeneration,
  // 输出警告信息，指出哪个算法的密钥生成使用了无法静态验证的密钥大小
  "算法 " + algorithmName.toString() + " 的密钥生成使用了无法静态验证的密钥大小，配置源位于 $@", keyConfiguration, keyConfiguration.toString()