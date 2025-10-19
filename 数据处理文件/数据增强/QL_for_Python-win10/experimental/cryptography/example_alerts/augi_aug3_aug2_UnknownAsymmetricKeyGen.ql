/**
 * @name 非对称密钥生成中使用未知密钥大小
 * @description 识别在非对称加密密钥生成过程中使用无法通过静态分析验证的密钥长度的安全风险
 * @id py/unknown-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// 检测非对称密钥生成操作中密钥大小无法静态验证的实例
from AsymmetricKeyGen keyGenerationOperation, DataFlow::Node configSourceNode, string algorithmIdentifier
where
  // 提取密钥配置的源节点信息
  configSourceNode = keyGenerationOperation.getKeyConfigSrc() and
  // 获取当前密钥生成操作所使用的加密算法标识
  algorithmIdentifier = keyGenerationOperation.getAlgorithm().getName() and
  // 验证该密钥生成操作是否缺乏静态可验证的密钥大小配置
  not keyGenerationOperation.hasKeySize(configSourceNode)
select keyGenerationOperation,
  // 生成安全警告，标识算法名称及配置源位置
  "算法 " + algorithmIdentifier.toString() + " 的密钥生成使用了无法静态验证的密钥大小，配置源位于 $@", configSourceNode, configSourceNode.toString()