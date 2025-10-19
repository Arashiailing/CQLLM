/**
 * @name 未知密钥生成密钥大小
 * @description 检测非对称密钥生成时使用了无法静态验证的密钥大小
 * @id py/unknown-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// 查询非对称密钥生成操作中未验证密钥大小的配置源
from AsymmetricKeyGen keyGen, DataFlow::Node configNode, string algorithmName
where
  // 获取密钥配置源节点
  configNode = keyGen.getKeyConfigSrc() and
  // 获取算法名称
  algorithmName = keyGen.getAlgorithm().getName() and
  // 验证密钥大小是否缺失静态验证
  not keyGen.hasKeySize(configNode)
select keyGen,
  // 输出包含算法名称和配置源的诊断信息
  "用于算法 " + algorithmName.toString() + " 的密钥生成使用了无法静态验证的密钥大小，在配置源 $@", 
  configNode, 
  configNode.toString()