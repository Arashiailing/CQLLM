/**
 * @name 非对称密钥生成中使用未知密钥大小
 * @description 检测非对称密钥生成过程中使用了无法静态验证的密钥大小的情况
 * @id py/unknown-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// 查询所有非对称密钥生成操作，其中密钥大小无法静态验证
from AsymmetricKeyGen asymmetricKeyGen, DataFlow::Node keyConfigNode, string algoName
where
  // 获取密钥配置的来源节点
  keyConfigNode = asymmetricKeyGen.getKeyConfigSrc() and
  // 获取使用的加密算法名称
  algoName = asymmetricKeyGen.getAlgorithm().getName() and
  // 确认密钥生成操作没有静态验证的密钥大小
  not asymmetricKeyGen.hasKeySize(keyConfigNode)
select asymmetricKeyGen,
  // 输出警告信息，指出哪个算法的密钥生成使用了无法静态验证的密钥大小
  "算法 " + algoName.toString() + " 的密钥生成使用了无法静态验证的密钥大小，配置源位于 $@", keyConfigNode, keyConfigNode.toString()