/**
 * @name 未知密钥生成密钥大小
 * @description 检测非对称密钥生成操作中无法静态验证密钥大小的配置
 * @id py/unknown-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// 查找非对称密钥生成操作，并分析其配置源和算法信息
from AsymmetricKeyGen keyGenOperation, DataFlow::Node configSource, string algoName
where
  // 提取密钥生成操作的配置源节点
  configSource = keyGenOperation.getKeyConfigSrc()
  and
  // 获取密钥生成算法的名称
  algoName = keyGenOperation.getAlgorithm().getName()
  and
  // 检查密钥大小是否无法静态验证
  not keyGenOperation.hasKeySize(configSource)
select keyGenOperation,
  // 构建包含算法名称和配置源位置的诊断消息
  "用于算法 " + algoName.toString() + " 的密钥生成使用了无法静态验证的密钥大小，在配置源 $@", configSource, configSource.toString()