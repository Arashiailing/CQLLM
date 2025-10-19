/**
 * @name 非对称密钥生成中使用未知密钥大小
 * @description 检测在非对称密钥生成过程中使用了无法静态验证的密钥大小的安全漏洞。
 *              此类情况可能导致系统使用弱密钥或不符合安全标准的密钥，从而增加被攻击的风险。
 * @id py/unknown-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// 查询所有非对称密钥生成操作，其中密钥大小无法通过静态分析验证
from AsymmetricKeyGen keyGenOperation, DataFlow::Node keyConfigSource, string algorithmName
where
  // 获取密钥配置来源节点和加密算法名称
  keyConfigSource = keyGenOperation.getKeyConfigSrc()
  and
  algorithmName = keyGenOperation.getAlgorithm().getName()
  and
  // 检查密钥生成操作是否缺乏静态可验证的密钥大小
  not keyGenOperation.hasKeySize(keyConfigSource)
select keyGenOperation,
  // 构建告警信息，指明具体算法的密钥生成使用了无法静态验证的密钥大小
  "算法 " + algorithmName.toString() + " 的密钥生成使用了无法静态验证的密钥大小，配置源位于 $@", keyConfigSource, keyConfigSource.toString()