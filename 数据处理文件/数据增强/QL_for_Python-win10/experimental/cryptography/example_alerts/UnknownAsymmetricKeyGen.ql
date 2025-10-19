/**
 * @name 未知密钥生成密钥大小
 * @description
 * @id py/unknown-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// 从 AsymmetricKeyGen 操作和数据流节点 configSrc 以及字符串类型的算法名称 algName 中进行查询
from AsymmetricKeyGen op, DataFlow::Node configSrc, string algName
where
  // 检查操作对象是否没有静态验证的密钥大小
  not op.hasKeySize(configSrc) and
  // 获取配置源
  configSrc = op.getKeyConfigSrc() and
  // 获取算法名称
  algName = op.getAlgorithm().getName()
select op,
  // 选择操作对象，并输出包含算法名称和配置源的信息
  "用于算法 " + algName.toString() + " 的密钥生成使用了无法静态验证的密钥大小，在配置源 $@", configSrc, configSrc.toString()
