/**
 * @name 未知密钥生成密钥大小
 * @description 识别在非对称加密密钥生成过程中，密钥大小参数无法通过静态分析验证的代码实例
 * @id py/unknown-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// 查询非对称密钥生成操作及其配置源
from AsymmetricKeyGen keyGenOperation, DataFlow::Node configSource
where
  // 获取密钥配置源
  configSource = keyGenOperation.getKeyConfigSrc() and
  // 验证操作是否缺少静态可验证的密钥大小
  not keyGenOperation.hasKeySize(configSource)
select keyGenOperation,
  // 获取算法名称并输出包含算法名称和配置源的诊断信息
  "算法 " + keyGenOperation.getAlgorithm().getName() + " 的密钥生成使用了无法静态验证的密钥大小，配置源位于 $@", configSource, configSource.toString()