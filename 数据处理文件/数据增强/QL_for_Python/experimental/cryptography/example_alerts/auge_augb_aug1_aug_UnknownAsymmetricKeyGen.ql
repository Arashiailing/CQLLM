/**
 * @name 非对称密钥生成中的未知密钥大小
 * @description 检测非对称加密算法生成密钥时，无法在静态分析阶段确定密钥长度的情况
 * @id py/unknown-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// 检测非对称密钥生成操作中密钥大小无法静态确认的情况
from AsymmetricKeyGen keyGenOperation, DataFlow::Node keyConfigSource, string algoName
where
  // 获取密钥生成操作的配置源节点
  keyConfigSource = keyGenOperation.getKeyConfigSrc()
  and
  // 获取使用的加密算法名称
  algoName = keyGenOperation.getAlgorithm().getName()
  and
  // 验证密钥生成操作缺乏静态可验证的密钥大小参数
  not keyGenOperation.hasKeySize(keyConfigSource)
select keyGenOperation,
  // 生成包含算法信息和配置源的问题报告
  "用于算法 " + algoName.toString() + " 的密钥生成使用了无法静态验证的密钥大小，在配置源 $@", keyConfigSource, keyConfigSource.toString()