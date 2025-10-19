/**
 * @name 非对称密钥生成中使用未知密钥大小
 * @description 检测非对称密钥生成过程中使用了无法静态验证的密钥大小的安全漏洞。
 *              使用不可验证的密钥大小可能导致弱密钥或不符合安全标准的密钥，从而增加系统被攻击的风险。
 * @id py/unknown-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// 定位所有非对称密钥生成操作，其中密钥大小无法通过静态分析确定
from AsymmetricKeyGen asymmetricKeyGeneration, DataFlow::Node configurationSource, string algorithmName
where
  // 获取密钥配置的来源节点和使用的加密算法名称
  configurationSource = asymmetricKeyGeneration.getKeyConfigSrc()
  and algorithmName = asymmetricKeyGeneration.getAlgorithm().getName()
  and
  // 确认密钥生成操作确实没有静态可验证的密钥大小
  not asymmetricKeyGeneration.hasKeySize(configurationSource)
select asymmetricKeyGeneration,
  // 构建告警消息，指出特定算法的密钥生成使用了无法静态验证的密钥大小
  "算法 " + algorithmName.toString() + " 的密钥生成使用了无法静态验证的密钥大小，配置源位于 $@", configurationSource, configurationSource.toString()