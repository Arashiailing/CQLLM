/**
 * @name 未知密钥生成密钥大小
 * @description 检测非对称密钥生成操作中使用了无法静态验证的密钥大小的情况
 * @id py/unknown-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// 查找非对称密钥生成操作，其中密钥大小无法通过静态分析验证
from AsymmetricKeyGen keyGenOperation, DataFlow::Node keyConfigSource, string encryptionAlgorithm
where
  // 提取密钥配置源和算法信息
  keyConfigSource = keyGenOperation.getKeyConfigSrc() and
  encryptionAlgorithm = keyGenOperation.getAlgorithm().getName() and
  // 检查密钥生成操作是否缺少静态可验证的密钥大小
  not keyGenOperation.hasKeySize(keyConfigSource)
select keyGenOperation,
  // 构建警报消息，包含算法信息和配置源位置
  "用于算法 " + encryptionAlgorithm.toString() + " 的密钥生成使用了无法静态验证的密钥大小，在配置源 $@", keyConfigSource, keyConfigSource.toString()