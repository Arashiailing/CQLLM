/**
 * @name 非对称密钥生成中的未知密钥大小
 * @description 检测非对称密钥生成操作中使用了无法静态验证的密钥大小的情况
 * @id py/unknown-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// 识别非对称密钥生成操作，其中密钥大小无法通过静态分析验证
from AsymmetricKeyGen keyGeneration, DataFlow::Node keyConfigSource, string algorithmName
where
  // 提取密钥配置源和算法名称信息
  keyConfigSource = keyGeneration.getKeyConfigSrc() and
  algorithmName = keyGeneration.getAlgorithm().getName() and
  // 验证密钥生成操作是否缺乏静态可验证的密钥大小
  not keyGeneration.hasKeySize(keyConfigSource)
select keyGeneration,
  // 生成安全警告，标明算法类型和配置源位置
  "用于算法 " + algorithmName.toString() + " 的密钥生成使用了无法静态验证的密钥大小，在配置源 $@", keyConfigSource, keyConfigSource.toString()