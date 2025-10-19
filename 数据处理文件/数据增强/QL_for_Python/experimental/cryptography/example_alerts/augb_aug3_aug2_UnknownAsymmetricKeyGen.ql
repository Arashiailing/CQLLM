/**
 * @name 非对称密钥生成中使用未知密钥大小
 * @description 识别在非对称密钥生成过程中使用了无法静态验证的密钥大小的安全风险。
 *              这种情况可能导致使用弱密钥或不符合安全标准的密钥，增加系统被攻击的风险。
 * @id py/unknown-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// 查找所有非对称密钥生成操作，其中密钥大小无法通过静态分析验证
from AsymmetricKeyGen keyGenOp, DataFlow::Node configSrc, string algoName
where
  // 获取密钥配置的来源节点
  configSrc = keyGenOp.getKeyConfigSrc()
  and
  // 提取所使用的加密算法名称
  algoName = keyGenOp.getAlgorithm().getName()
  and
  // 验证密钥生成操作确实没有静态可验证的密钥大小
  not keyGenOp.hasKeySize(configSrc)
select keyGenOp,
  // 生成告警信息，指明具体算法的密钥生成使用了无法静态验证的密钥大小
  "算法 " + algoName.toString() + " 的密钥生成使用了无法静态验证的密钥大小，配置源位于 $@", configSrc, configSrc.toString()