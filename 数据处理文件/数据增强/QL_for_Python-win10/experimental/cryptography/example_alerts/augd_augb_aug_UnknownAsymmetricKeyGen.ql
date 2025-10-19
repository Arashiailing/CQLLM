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

// 查找所有非对称密钥生成操作，其中密钥大小无法被静态验证
from AsymmetricKeyGen keyGeneration, DataFlow::Node configurationSource, string algorithmName
where
  // 获取密钥配置源节点
  configurationSource = keyGeneration.getKeyConfigSrc() and
  // 获取使用的算法名称
  algorithmName = keyGeneration.getAlgorithm().getName() and
  // 检查该密钥生成操作是否缺少静态可验证的密钥大小
  not keyGeneration.hasKeySize(configurationSource)
select keyGeneration,
  // 生成告警消息，包含算法信息和配置源位置
  "用于算法 " + algorithmName.toString() + " 的密钥生成使用了无法静态验证的密钥大小，在配置源 $@", 
  configurationSource, 
  configurationSource.toString()