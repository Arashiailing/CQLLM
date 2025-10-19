/**
 * @name 非对称密钥生成中使用未知密钥大小
 * @description 检测在非对称密钥生成过程中使用了无法静态验证的密钥大小的安全漏洞。
 *              这种做法可能导致使用弱密钥或不符合安全标准的密钥，从而增加系统被攻击的风险。
 * @id py/unknown-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// 查找非对称密钥生成操作，其中密钥大小无法通过静态分析确定
from AsymmetricKeyGen keyGeneration, DataFlow::Node configSource, string algorithmName
where
  // 确定密钥配置的来源节点
  configSource = keyGeneration.getKeyConfigSrc()
  and
  // 获取加密算法的名称
  algorithmName = keyGeneration.getAlgorithm().getName()
  and
  // 检查密钥生成操作是否缺少静态可验证的密钥大小
  not keyGeneration.hasKeySize(configSource)
select keyGeneration,
  // 构建告警消息，指出特定算法的密钥生成使用了无法静态验证的密钥大小
  "算法 " + algorithmName.toString() + " 的密钥生成使用了无法静态验证的密钥大小，配置源位于 $@", configSource, configSource.toString()