/**
 * @name 非对称密钥生成中的未知密钥大小
 * @description 识别在非对称加密密钥生成过程中使用无法静态确定密钥长度的操作
 * @id py/unknown-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// 检测非对称密钥生成操作中密钥大小无法静态确认的情况
from AsymmetricKeyGen cryptoKeyGen, DataFlow::Node keyConfigNode, string cryptoAlgorithm
where
  // 获取密钥配置源节点
  keyConfigNode = cryptoKeyGen.getKeyConfigSrc() and
  // 获取所使用的加密算法名称
  cryptoAlgorithm = cryptoKeyGen.getAlgorithm().getName() and
  // 确认密钥生成操作没有静态验证的密钥大小参数
  not cryptoKeyGen.hasKeySize(keyConfigNode)
select cryptoKeyGen,
  // 生成问题报告，包含算法信息和配置源
  "用于算法 " + cryptoAlgorithm.toString() + " 的密钥生成使用了无法静态验证的密钥大小，在配置源 $@", keyConfigNode, keyConfigNode.toString()