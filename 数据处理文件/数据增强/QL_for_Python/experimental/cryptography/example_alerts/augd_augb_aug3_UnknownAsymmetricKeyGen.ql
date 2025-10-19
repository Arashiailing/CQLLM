/**
 * @name 非对称密钥生成中密钥大小无法静态验证
 * @description 检测非对称加密密钥生成时密钥大小参数无法通过静态分析确定的代码模式
 * @id py/unknown-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// 查找非对称密钥生成操作及其配置来源
from AsymmetricKeyGen keyGeneration, DataFlow::Node keyConfigSource
where
  // 获取密钥配置来源节点
  keyConfigSource = keyGeneration.getKeyConfigSrc() and
  // 验证密钥大小是否缺失静态可验证性
  not keyGeneration.hasKeySize(keyConfigSource)
select keyGeneration,
  // 构建包含算法名称和配置源的诊断信息
  ("算法 " + 
   keyGeneration.getAlgorithm().getName() + 
   " 的密钥生成使用了无法静态验证的密钥大小，配置源位于 $@"), 
  keyConfigSource, 
  keyConfigSource.toString()