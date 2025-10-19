/**
 * @name 非对称密钥生成中使用未知密钥大小
 * @description 检测在非对称密钥生成过程中使用了无法通过静态分析验证的密钥大小的情况。
 *              这种做法可能导致使用弱密钥或不符合安全标准的密钥，从而增加系统被攻击的风险。
 * @id py/unknown-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// 本查询旨在识别非对称密钥生成过程中的安全风险：使用无法静态验证的密钥大小
// 此类风险可能导致系统采用弱密钥或不符合安全标准的密钥，增加被攻击的可能性
from 
  AsymmetricKeyGen asymmetricKeyGeneration,  // 表示非对称密钥生成操作
  DataFlow::Node keyConfigSource,           // 表示密钥配置的来源节点
  string algorithmName                      // 表示所使用的加密算法名称
where 
  // 获取密钥配置的来源节点
  keyConfigSource = asymmetricKeyGeneration.getKeyConfigSrc()
  and 
  // 提取所使用的加密算法名称
  algorithmName = asymmetricKeyGeneration.getAlgorithm().getName()
  and 
  // 验证密钥生成操作确实没有静态可验证的密钥大小
  not asymmetricKeyGeneration.hasKeySize(keyConfigSource)
select 
  asymmetricKeyGeneration,
  // 构建告警信息，指明具体算法的密钥生成使用了无法静态验证的密钥大小
  "算法 " + algorithmName.toString() + " 的密钥生成使用了无法静态验证的密钥大小，配置源位于 $@", 
  keyConfigSource, 
  keyConfigSource.toString()