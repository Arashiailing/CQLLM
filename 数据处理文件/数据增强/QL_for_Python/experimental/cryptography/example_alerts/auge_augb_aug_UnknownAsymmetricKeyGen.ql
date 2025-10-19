/**
 * @name 非对称密钥生成中的未知密钥大小
 * @description 识别在非对称密钥生成过程中使用了无法静态确定密钥尺寸的场景
 * @id py/unknown-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// 定位非对称密钥生成操作，其中密钥尺寸无法静态验证
from AsymmetricKeyGen keyGenOperation, DataFlow::Node keyConfigNode, string algorithmName
where
  // 提取密钥配置源和算法标识
  keyConfigNode = keyGenOperation.getKeyConfigSrc() and
  algorithmName = keyGenOperation.getAlgorithm().getName() and
  // 验证密钥生成操作缺乏静态可验证的密钥尺寸
  not keyGenOperation.hasKeySize(keyConfigNode)
select keyGenOperation,
  // 生成告警信息，包含算法类型和配置源详情
  "算法 " + algorithmName.toString() + " 的密钥生成使用了无法静态验证的密钥大小，配置源自 $@", keyConfigNode, keyConfigNode.toString()