/**
 * @name 非对称密钥生成中的未知密钥大小
 * @description 识别非对称加密算法生成密钥时，密钥长度无法在静态分析阶段确定的场景
 * @id py/unknown-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// 检测非对称密钥生成操作中密钥大小无法静态确认的情况
from AsymmetricKeyGen keyGenOp, DataFlow::Node keyConfigSource, string cryptoAlgorithm
where
  // 获取所使用的加密算法名称
  cryptoAlgorithm = keyGenOp.getAlgorithm().getName() and
  // 获取密钥配置的源节点
  keyConfigSource = keyGenOp.getKeyConfigSrc() and
  // 确认密钥生成操作没有静态验证的密钥大小参数
  not keyGenOp.hasKeySize(keyConfigSource)
select keyGenOp,
  // 生成问题报告，包含算法信息和配置源
  "用于算法 " + cryptoAlgorithm.toString() + " 的密钥生成使用了无法静态验证的密钥大小，在配置源 $@", keyConfigSource, keyConfigSource.toString()