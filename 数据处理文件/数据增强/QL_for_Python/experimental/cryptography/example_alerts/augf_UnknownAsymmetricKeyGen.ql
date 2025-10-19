/**
 * @name 非对称密钥生成中密钥大小不可静态验证
 * @description 检测非对称密钥生成操作中使用了无法静态验证的密钥大小配置
 * @id py/unknown-asymmetric-key-gen-size
 * @kind problem
 * @severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// 查询所有非对称密钥生成操作，其中密钥大小无法静态验证
from AsymmetricKeyGen keyGenOperation, DataFlow::Node configSource, string algorithmName
where
  // 验证密钥生成操作是否存在静态验证的密钥大小
  not keyGenOperation.hasKeySize(configSource) and
  // 获取密钥配置源
  configSource = keyGenOperation.getKeyConfigSrc() and
  // 获取使用的加密算法名称
  algorithmName = keyGenOperation.getAlgorithm().getName()
select keyGenOperation,
  // 报告问题，显示算法名称和配置源位置
  "算法 " + algorithmName + " 的密钥生成使用了无法静态验证的密钥大小，配置源位于 $@", configSource, configSource.toString()