/**
 * @name 非对称密钥生成中使用未知密钥大小
 * @description 检测非对称密钥生成操作中使用了无法静态验证的密钥大小
 * @id py/unknown-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// 从非对称密钥生成操作、密钥配置源节点和算法名称中查询
from AsymmetricKeyGen keyGenOperation, DataFlow::Node keyConfigSource, string algorithmName
where
  // 获取密钥配置源
  keyConfigSource = keyGenOperation.getKeyConfigSrc() and
  // 获取算法名称
  algorithmName = keyGenOperation.getAlgorithm().getName() and
  // 验证密钥大小是否无法静态确定
  not keyGenOperation.hasKeySize(keyConfigSource)
select keyGenOperation,
  // 输出警告信息，包含算法名称和配置源位置
  "用于算法 " + algorithmName.toString() + " 的密钥生成使用了无法静态验证的密钥大小，在配置源 $@", keyConfigSource, keyConfigSource.toString()