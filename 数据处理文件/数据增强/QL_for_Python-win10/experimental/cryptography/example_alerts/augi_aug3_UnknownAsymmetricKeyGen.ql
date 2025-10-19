/**
 * @name 非对称密钥生成中的未知密钥大小
 * @description 识别在非对称密钥生成过程中，密钥大小无法通过静态分析验证的配置
 * @id py/unknown-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// 查找所有非对称密钥生成操作，并提取其配置源和算法信息
from AsymmetricKeyGen asymKeyGen, DataFlow::Node keyConfigNode, string cryptoAlgorithm
where
  // 提取密钥配置源节点
  keyConfigNode = asymKeyGen.getKeyConfigSrc() and
  // 获取所使用的加密算法名称
  cryptoAlgorithm = asymKeyGen.getAlgorithm().getName() and
  // 检查该密钥生成操作是否缺少可静态验证的密钥大小设置
  not asymKeyGen.hasKeySize(keyConfigNode)
select asymKeyGen,
  // 生成包含算法信息和配置源的诊断消息
  "算法 " + cryptoAlgorithm.toString() + " 的密钥生成操作使用了无法静态验证的密钥大小，配置源位于 $@", keyConfigNode, keyConfigNode.toString()