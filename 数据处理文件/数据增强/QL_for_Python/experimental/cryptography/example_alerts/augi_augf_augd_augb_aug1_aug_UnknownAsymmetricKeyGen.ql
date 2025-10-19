/**
 * @name 非对称密钥生成中的未知密钥大小
 * @description 检测非对称加密算法在密钥生成时，密钥长度无法通过静态分析确认的潜在安全风险
 * @id py/unknown-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// 查找非对称密钥生成实例，其中密钥尺寸参数无法静态确定
from AsymmetricKeyGen keyGenOperation, DataFlow::Node keyConfigOrigin, string cryptoAlgorithm
where
  // 获取密钥配置的原始数据流节点，用于定位密钥参数的输入位置
  keyConfigOrigin = keyGenOperation.getKeyConfigSrc() and
  // 提取当前密钥生成操作所采用的加密算法标识
  cryptoAlgorithm = keyGenOperation.getAlgorithm().getName() and
  // 确认密钥生成操作是否缺乏静态可验证的密钥长度参数
  not keyGenOperation.hasKeySize(keyConfigOrigin)
select keyGenOperation,
  // 构建安全警告消息，标识具体算法和不可验证的密钥配置来源
  "算法 " + cryptoAlgorithm.toString() + " 的密钥生成过程使用了无法静态验证的密钥大小，配置源位于 $@", keyConfigOrigin, keyConfigOrigin.toString()