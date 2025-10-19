/**
 * @name 非对称密钥生成中的未知密钥大小
 * @description 检测在非对称加密密钥生成过程中，密钥长度无法静态确定的场景
 * @id py/unknown-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// 查找非对称密钥生成操作中密钥大小无法静态验证的实例
from AsymmetricKeyGen asymmetricKeyGen, DataFlow::Node keySizeConfigNode, string encryptionAlgorithm
where
  // 获取加密算法名称
  encryptionAlgorithm = asymmetricKeyGen.getAlgorithm().getName() and
  // 获取密钥配置源节点
  keySizeConfigNode = asymmetricKeyGen.getKeyConfigSrc() and
  // 验证密钥生成操作是否缺乏静态可验证的密钥大小参数
  not asymmetricKeyGen.hasKeySize(keySizeConfigNode)
select asymmetricKeyGen,
  // 构建包含算法详情和配置源的问题报告
  "算法 " + encryptionAlgorithm.toString() + " 的密钥生成使用了无法静态验证的密钥大小，配置源位于 $@", keySizeConfigNode, keySizeConfigNode.toString()